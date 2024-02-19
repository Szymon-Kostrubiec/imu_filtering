#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Raport Kalman",
  authors: (
    "Szymon",
  ),
)

#set math.mat(delim: "[")

// We generated the example code below so you can see how
// your document will look. Go ahead and replace it with
// your own content!

= MPU9250 Settings

=== Gyroscope

Scale: $plus.minus 250 "rad"/s$

Sample rate: $3.6 "kSa/s"$
Can be set to $8.8 "kSa/s"$

Internal DLPF off.

=== Accelerometer

Scale: $plus.minus 2 "g "$. _The ecompass algorithm operates under no acceleration assumption_

Sample rate: $1.13 "kSa/s"$

Noise density: $250 (mu g) / ("rt" "Hz")$ // Dowiedzieć się, co to znaczy

=== Magnetometer

Scale is fixed at $plus.minus 4800 mu "T"$.

Sample rate is $100 "Sa/s"$ (MODE2). // directly from AK8963 datasheet

= Filtering schemes

=== Extended Kalman Filter

_In case the magnetometer is not used, the yaw angle is estimated from the gyroscope measurements only_. That is, the observation of the yaw angle is taken from the state vector. The equations remain unchanged.

State:
$ x(k) = mat(bold(q); omega_w; omega_u; omega_v) $

The angular velocities refer to the local frame.

Update equation

$ bold(x)_(k+1|k) = bold(F)(t) bold(x)_(k) = mat(q; omega_w; omega_u; omega_v) = mat(
1, omega_w, -omega_v, omega_u, 0, 0, 0;
-omega_w, 1, omega_u, omega_v, 0, 0, 0;
omega_v, -omega_u, 1, omega_w, 0, 0, 0;
-omega_u, -omega_v, -omega_w, 1, 0, 0, 0;
0, 0, 0, 0, 1, 0, 0;
0, 0, 0, 0, 0, 1, 0;
0, 0, 0, 0, 0, 0, 1) mat(q_w; q_x; q_y; q_z; omega_w; omega_u; omega_v) $

===== Dealing with different sample rates for the sensors

Since the gyroscope could be sampled much more quickly, it has a separate update equation to allow for sampling and updating independently of the accelerometer/magnetometer pair.

Additionally, since the accelerometer is also sampled much more quickly than the magnetometer, the magnetometer data is interpolated.

Interpolation scheme:
- assumption of being constant inbetween measurements
- linear interpolation (?)
- separate LKF for the magnetometer (?)

Measurements vector:
$ y = mat(omega_w; omega_u; omega_v; a_x; a_y; a_z; M_x; M_y) $

Magnetometer measures the magnetic field strength in the global frame $M$. The magnetic field strength in the local frame is denoted as $m$.

$M_Z$ is not estimated. It is dependent on the exact location on Earth. // ?

===== Mapping the state space to the measurement space: the observation equations

$ omega_w = omega_w $
$ omega_u = omega_u $
$ omega_v = omega_v $

Using the Euler angles: // sprawdzic katy
$ psi = arctan((2 q_w q_x + q_y q_z) / (1 - 2(q_x^2 + q_y^2)))  $ // atan2 in code
$ theta = (-pi) / 2 + 2 arctan((sqrt(1 + 2 (q_w q_y - q_x q_z))) / (sqrt(1 - 2(q_w q_y - q_x q_z)))) $
$ phi.alt = arctan((2 (q_w q_z + q_x q_y)) / (1 - 2(q_y^2 q_z^2))) $

Numerical problems around 0 and 1. // verify

$ a_x = sin(theta) $
$ a_y = -cos(theta) sin(psi) $
$ a_z = cos(theta) cos(psi) $

$ m_x =  $
$ m_y =  $

====== Observation matrix Jacobian

```
jac =
 
[(cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2), -(cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2), (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2), -(cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2), 0, 0, 0]
[                  - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2) + (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2),                                                               (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2) - (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2),                                                           - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2) + (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2),                   (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2) - (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*((imag(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)/((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2), 0, 0, 0]
[- (2*cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*imag(q_x))/abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(q_x*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1)*2i + conj(q_x)*(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*2i)*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(2*abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)^2*(-(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))^(1/2)) - (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_y/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_y/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)), - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(2*imag(q_w) + 4*real(q_x)))/abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((conj(q_w)*2i + 4*conj(q_x))*(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) + (q_w*2i - 4*q_x)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(2*abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)^2*(-(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))^(1/2)) + (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_z/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_z/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)), - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag(q_z) + 4*real(q_y)))/abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((4*conj(q_y) + conj(q_z)*1i)*(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) - (4*q_y - q_z*1i)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(2*abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)^2*(-(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))^(1/2)) - (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_w/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_w/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)), - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*imag(q_y))/abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1) - (cos(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(q_y*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1)*1i + conj(q_y)*(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*1i)*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(2*abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)^2*(-(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*(conj(q_w)*conj(q_x)*2i + conj(q_y)*conj(q_z)*1i + 2*conj(q_x)^2 + 2*conj(q_y)^2 - 1))^(1/2)) + (sin(pi/2 - atan2((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2), (2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*((imag(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) - real(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2))) + ((imag(q_x/(2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) + real(q_x/(2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))*(imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2))))/(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)*(imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2*(2*real(q_x^2) + 2*real(q_y^2) + imag(q_y*q_z) - real(q_w*q_x*2i) - 1))/(abs(- 2*q_x^2 + q_w*q_x*2i - 2*q_y^2 + q_z*q_y*1i + 1)*((imag((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)) + real((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)))^2 + (imag((2*q_w*q_y - 2*q_x*q_z + 1)^(1/2)) - real((2*q_x*q_z - 2*q_w*q_y + 1)^(1/2)))^2)), 0, 0, 0]
```

=== Error-State Extended Kalman Filter

===== Dealing with gyroscope bias

Commonly, there is a thermal model that is used to estimate the gyroscope bias. However, Machony et al. proved, that since the bias is a DC component of the measurements, it can be estimated via integration:

$ b_i = integral_(0)^t omega_i dif t $

To allow the sensor to change environments rapidly, I (plan to) use the so-called leaky integrator:

$ b_i = integral_(t - T)^t omega_i dif t $

The time constant $T$ can be used to tune the filter. Additionally, the leaky integrator is trivial to implement.

=== Magdwick filter

// === Dealing with noise

// SVD for noise identification
// FFT for noise spectrum



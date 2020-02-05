function Y = full_regressor_plnr(in1,in2,in3)
%FULL_REGRESSOR_PLNR
%    Y = FULL_REGRESSOR_PLNR(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    03-Feb-2020 10:03:33

q1 = in1(1,:);
q2 = in1(2,:);
q2d1 = in3(1,:);
q2d2 = in3(2,:);
qd1 = in2(1,:);
qd2 = in2(2,:);
t2 = sin(1.5708);
t3 = cos(q2);
t4 = sin(q2);
t5 = cos(q1);
t6 = sin(q1);
t7 = qd2.^2;
t8 = t2.*t5.*(9.81e2./1.0e2);
t9 = q2d1+q2d2;
t10 = t2.*t3.*t5.*(9.81e2./1.0e2);
t11 = qd1.^2;
Y = reshape([0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,q2d1,0.0,t8,0.0,t2.*t6.*(-9.81e2./1.0e2),0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,t9,t9,t10+q2d1.*t3.*2.0+q2d2.*t3-t4.*t7-qd1.*qd2.*t4.*2.0-t2.*t4.*t6.*(9.81e2./1.0e2),t10+q2d1.*t3+t4.*t11-t2.*t4.*t6.*(9.81e2./1.0e2),q2d1.*t4.*-2.0-q2d2.*t4-t3.*t7-qd1.*qd2.*t3.*2.0-t2.*t3.*t6.*(9.81e2./1.0e2)-t2.*t4.*t5.*(9.81e2./1.0e2),-q2d1.*t4+t3.*t11-t2.*t3.*t6.*(9.81e2./1.0e2)-t2.*t4.*t5.*(9.81e2./1.0e2),0.0,0.0,q2d1+t8,0.0],[2,20]);
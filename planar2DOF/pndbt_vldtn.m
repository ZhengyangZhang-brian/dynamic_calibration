% -----------------------------------------------------------------------
% In this script I carry out validation of identified inertial parameters 
% of the pendubot. 
% -----------------------------------------------------------------------

% load and process pendubot data for valication
vldtnData = {};
vldtnData{1} = pendubotDataProcessing('position_A_0.3141_v_0.5.mat');
vldtnData{2} = pendubotDataProcessing('position_A_0.3141_v_1.mat');
vldtnData{3} = pendubotDataProcessing('position_A_0.3141_v_2.mat');
%  vldtnData{3} = pendubotDataProcessing('step_A_1.57.mat');


%%
% get inertial parameters from CAD to compare with identification
pi_CAD = [plnr.pi(:,1); 0; plnr.pi(:,2)];

% based on generalized positions, velocities and accelerations and using
% regressor form predict torques
vldtnRange = 1:1000;%size(vldtnData.time,1);
tau_prdctd_CAD = {}; tau_prdctd_SDP = {};
for i = 1:3
    [vldtnData{i}.tau_prdctd_CAD, vldtnData{i}.tau_prdctd_SDP{1}] = ...
                dynamicParametrsValidationForPendubot(vldtnData{i}, vldtnRange, pi_CAD, [pi_stnd{1}; pi_frctn{1}]);
    for k = 2:3
        [~, vldtnData{i}.tau_prdctd_SDP{k}] = dynamicParametrsValidationForPendubot(...
                                                vldtnData{i}, vldtnRange, pi_CAD, [pi_stnd{k}; pi_frctn{k}]);
    end
end

%% Validation of statics
q_sttcs(:,1) = [0.037, -1.598]'; 
q_sttcs(:,2) = [-1.2, -0.36]'; 
q_sttcs(:,3) = [-0.8, -0.764]';

tau_sttcs(1) = -1.3 ;
tau_sttcs(2) = -0.4;
tau_sttcs(3) = -0.87;

for i = 1:3
    Y_sttcs(:,:,i) = regressorWithMotorDynamicsPndbt(q_sttcs(:,i), zeros(2,1), zeros(2,1));
    Yfrctn_sttcs(:,:,i) = frictionRegressor(zeros(2,1));
end

for i = 1:3
   for k = 1:3
      tau_hat_sttcs(i,k) = ([Y_sttcs(:,:,i) Yfrctn_sttcs(:,:,i)]*[pi_stnd{k}; pi_frctn{k}])'*[1; 0]; 
   end
end


%% plot real torque and predictions

figure
subplot(3,1,1)
plot(vldtnData{1}.time(vldtnRange), vldtnData{1}.torque(vldtnRange),'r')
hold on
 plot(vldtnData{1}.time(vldtnRange), vldtnData{1}.tau_prdctd_CAD(1,:), 'k')
for k = 1:3
    plot(vldtnData{1}.time(vldtnRange), vldtnData{1}.tau_prdctd_SDP{k}(1,:))
end
legend('measured', 'predicted CAD', 'predicted OLS-SDP harmonic', 'predicted OLS-SDP step',  'predicted OLS-SDP polynomial')
grid on

subplot(3,1,2)
plot(vldtnData{2}.time(vldtnRange), vldtnData{2}.torque(vldtnRange),'r')
hold on
plot(vldtnData{2}.time(vldtnRange), vldtnData{2}.tau_prdctd_CAD(1,:), 'k')
for k = 1:3
    plot(vldtnData{2}.time(vldtnRange), vldtnData{2}.tau_prdctd_SDP{k}(1,:))
end
legend('measured', 'predicted CAD', 'predicted OLS-SDP harmonic', 'predicted OLS-SDP step',  'predicted OLS-SDP polynomial')
grid on

subplot(3,1,3)
plot(vldtnData{3}.time(vldtnRange), vldtnData{3}.torque(vldtnRange),'r')
hold on
plot(vldtnData{3}.time(vldtnRange), vldtnData{3}.tau_prdctd_CAD(1,:),'k')
for k = 1:3
    plot(vldtnData{3}.time(vldtnRange), vldtnData{3}.tau_prdctd_SDP{k}(1,:))
end
legend('measured', 'predicted CAD', 'predicted OLS-SDP harmonic', 'predicted OLS-SDP step',  'predicted OLS-SDP polynomial')
grid on


%% Local Functions
function [tau_prdctd_CAD, tau_prdctd_SDP] = dynamicParametrsValidationForPendubot(vldtnData, vldtnRange, pi_CAD, pi_hat_SDP)
    tau_prdctd_SDP = []; tau_prdctd_CAD = [];
    for i = vldtnRange
        qi = [vldtnData.shldr_position(i), vldtnData.elbw_position(i)]';
        qdi = [vldtnData.shldr_velocity(i), vldtnData.elbw_velocity(i)]';
        q2di = [vldtnData.shldr_acceleration(i), vldtnData.elbow_acceleration(i)]';

        
%         qi = [vldtnData.shldr_position_filtered(i), vldtnData.elbw_position_filtered(i)]';
%         qdi = [vldtnData.shldr_velocity_filtered(i), vldtnData.elbw_velocity_filtered(i)]';
%         q2di = [vldtnData.shldr_acceleration_filtered(i), vldtnData.elbow_acceleration_filtered(i)]';

        Yi = regressorWithMotorDynamicsPndbt(qi, qdi, q2di);
        Yfrctni = frictionRegressor(qdi);

        tau_prdctd_SDP = horzcat(tau_prdctd_SDP, [Yi, Yfrctni]*pi_hat_SDP);
        tau_prdctd_CAD = horzcat(tau_prdctd_CAD, Yi*pi_CAD);
    end
end
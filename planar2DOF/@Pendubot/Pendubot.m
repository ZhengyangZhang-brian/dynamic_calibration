classdef Pendubot
   properties
       description
       qr_decomposition
   end
   
   methods
       function obj = Pendubot(path_to_urdf)
           obj.description = parse_urdf(path_to_urdf);
           obj.qr_decomposition = load('qr_decomposition.mat');
       end
       
       generate_rigid_body_regressor_function(obj);
       get_base_parameters(obj);
       
       function pi = dynamic_parameters_from_urdf(obj, type)
           if strcmp(type, 'standard')
               pi = obj.description.pi(:);
           elseif strcmp(type, 'base')
               t1 = [eye(obj.qr_decomposition.no_base_parameters) ...
                        obj.qr_decomposition.beta];
               pi = t1*obj.qr_decomposition.permutation_matrix'*obj.description.pi(:);
           else 
               error('The parameters can be either standard or base');
           end
       end
       
       function Y = get_rigid_body_regressor(obj, q, q_dot, q_2dot, type)
           if strcmp(type, 'standard')
               Y = obj.get_standard_rigid_body_regressor(q, q_dot, q_2dot);
           elseif strcmp(type, 'base')
               Ystnd = obj.get_standard_rigid_body_regressor(q, q_dot, q_2dot);
               Y = Ystnd*obj.qr_decomposition.permutation_matrix(:,...
                                1:obj.qr_decomposition.no_base_parameters);
           else
               error('The parameters can be either standard or base');
           end
       end
       
       function pi_b = get_symbolic_base_parameters(obj)
           % Defining parameters symbolically
           m = sym('m%d',[2,1],'real');
           hx = sym('h%d_x',[2,1],'real');
           hy = sym('h%d_y',[2,1],'real');
           hz = sym('h%d_z',[2,1],'real');
           ixx = sym('i%d_xx',[2,1],'real');
           ixy = sym('i%d_xy',[2,1],'real');
           ixz = sym('i%d_xz',[2,1],'real');            
           iyy = sym('i%d_yy',[2,1],'real');
           iyz = sym('i%d_yz',[2,1],'real');
           izz = sym('i%d_zz',[2,1],'real'); 
           
           % Vector of symbolic parameters
           pi_pndbt_sym = {};
           for i = 1:2
               pi_pndbt_sym{i} = [ixx(i),ixy(i),ixz(i),iyy(i),iyz(i),izz(i),...
                                  hx(i),hy(i),hz(i),m(i)]';
           end
           pi_pndbt_sym = [pi_pndbt_sym{1}; pi_pndbt_sym{2}];
           
           % Find base parmaters
%            pi1 = E(:,1:bb)'*pi_pndbt_sym; % independent paramters
%            pi2 = E(:,bb+1:end)'*pi_pndbt_sym; % dependent paramteres

           % all of the expressions below are equivalent
           t1 = [eye(obj.qr_decomposition.no_base_parameters) ...
                        obj.qr_decomposition.beta];
           t2 = t1*obj.qr_decomposition.permutation_matrix';
           pi_b = t2*pi_pndbt_sym;
       end
   end
   
   methods (Static)
       Y = get_standard_rigid_body_regressor(q, q_dot, q_2dot);
   end
    
end
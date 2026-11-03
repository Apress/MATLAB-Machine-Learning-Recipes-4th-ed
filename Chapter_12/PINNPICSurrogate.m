phi = eval_2dpot_GS(phi);
GS_count = GS_count + 1;

if collect_snapshots
  if snapshots_taken < max_snapshots
    snapshot_counter = snapshot_counter + 1;
    if snapshot_counter >= snapshot_stride
      snapshot_counter = 0;
      snapshots_taken = snapshots_taken + 1;
      den_snap{snapshots_taken} = den; 
      phi_snap{snapshots_taken} = phi; %
      save('pinn_train_data.mat', ...
        'den_snap','phi_snap', ...
        'nx','ny','box','phi0','phi_p','n0','EPS0','QE','Te','dh');
      fprintf('Saved PINN snapshot %d / %d\n', ...
        snapshots_taken, max_snapshots);
    end
  end
end

layers = [
  featureInputLayer(3,"Normalization","none","Name","in")
  fullyConnectedLayer(128,"Name","fc1")
  tanhLayer("Name","t1")
  fullyConnectedLayer(128,"Name","fc2")
  tanhLayer("Name","t2")
  fullyConnectedLayer(128,"Name","fc3")
  tanhLayer("Name","t3")
  fullyConnectedLayer(128,"Name","fc4")
  tanhLayer("Name","t4")
  fullyConnectedLayer(1,"Name","out")
];
net = dlnetwork(layerGraph(layers));

L_data = mean( (phi_vec - targets).^2, 'all' );
L_pde = mean( res.^2, 'all' );
L_bc = dlarray(0.0);
diff_x0 = phi(1,:) - phi0;
L_bc = L_bc + mean(diff_x0.^2, 'all');
diff_xL = phi(nx,:) - phi(nx-1,:);
L_bc = L_bc + mean(diff_xL.^2, 'all');
diff_y0 = phi(:,1) - phi(:,2);
L_bc = L_bc + mean(diff_y0.^2, 'all');
diff_yL = phi(:,ny) - phi(:,ny-1);
L_bc = L_bc + mean(diff_yL.^2, 'all');
for j = box(2,1):box(2,2)
  plate_vals = phi(box(1,1):box(1,2), j);
  diff_plate = plate_vals - phi_p;
  L_bc = L_bc + mean(diff_plate.^2, 'all');
end
loss = L_data + lambda_pde * L_pde + lambda_bc * L_bc;
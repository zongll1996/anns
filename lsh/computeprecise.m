for i = 1:size(vquery,2)
  gnd_ids = ids_gnd(i);
  
    nn_pos = find (ids_pqc(i, :) == gnd_ids);
    
    if length (nn_pos) == 1
      nn_ranks_pqc (i) = nn_pos;
    else
      nn_ranks_pqc (i) = k + 1; 
    end
end
nn_ranks_pqc = sort (nn_ranks_pqc);
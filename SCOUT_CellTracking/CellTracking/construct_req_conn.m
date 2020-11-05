function total=construct_req_conn(num_sess,max_sess_dist,gap)
num_sess=num_sess-gap;
total=0;
for k=1:num_sess-1
    total=total+min(num_sess-k,max_sess_dist);
end

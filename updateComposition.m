function [alpha, X_h] = updateComposition ...
    (alpha, X, A, Q, f, nonetc, conn, erpunit, erpconn, tol)

sub = (Q<-tol*max(abs(Q)))' + 1;
nodeI = conn(sub2ind(size(conn), 1:size(conn,1), sub));
alpha_h = alpha(nodeI, :);
X_h = alpha_h * X;

sub_erp_I = (f(erpunit)<-tol*max(abs(f(erpunit))))' + 1;
sub_erp_J = ~(sub_erp_I-1) + 1;
nodeI_erp = erpconn(sub2ind(size(erpconn), 1:size(erpconn,1), sub_erp_I));
nodeJ_erp = erpconn(sub2ind(size(erpconn), 1:size(erpconn,1), sub_erp_J));

idx = setdiff(nonetc, nodeJ_erp);

q_in = max(A .* repmat(Q', size(A,1), 1), 0);
alpha(idx, :) = (q_in(idx, :)*alpha_h)./sum(q_in(idx,:),2);

alpha(nodeJ_erp, :) = alpha(nodeI_erp, :);

function pot = Vfunction(x,varargin)
V= varargin{1};
theta = varargin{2};
F = x(1);
chi = x(2);

pot = eval(subs(V));
end
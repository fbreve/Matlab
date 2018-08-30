function y = my_fun(b)
x = 0;
for i=1:15
    x = x + b(i+1)*2^(16-i);
end
if b(1)==0
    x=-x;
else
    x=x+1;
end
y = 2*x^4 - 3*x^3 + 7*x -5;

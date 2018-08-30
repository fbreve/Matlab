function rossler
    t_start = 0;
    t_end = 600;
    t_step = 0.01;
    x = 0;
    y = 0;
    z = 0;
    omega = 1;
    for t = t_start:t_step:t_end
        kx1 = t_step * dx(y, z, omega);
        ky1 = t_step * dy(x, y, omega);
        kz1 = t_step * dz(x, z);
        kx2 = t_step * dx(y+0.5*ky1, z+0.5*kz1, omega);
        ky2 = t_step * dy(x+0.5*kx1, y+0.5*ky1, omega);
        kz2 = t_step * dz(x+0.5*kx1, z+0.5*kz1);
        kx3 = t_step * dx(y+0.5*ky2, z+0.5*kz2, omega);
        ky3 = t_step * dy(x+0.5*kx2, y+0.5*ky2, omega);
        kz3 = t_step * dz(x+0.5*kx2, z+0.5*kz2);
        kx4 = t_step * dx(y+ky3, z+kz3, omega);
        ky4 = t_step * dy(x+kx3, y+ky3, omega);
        kz4 = t_step * dz(x+kx3, z+kz3);
        x = x + (kx1 + 2*kx2 + 2*kx3 + kx4)/6;
        y = y + (ky1 + 2*ky2 + 2*ky3 + ky4)/6;
        z = z + (kz1 + 2*kz2 + 2*kz3 + kz4)/6;
    end
    function dx = dx(y, z, omega)
        dx = -omega * y - z;
        return
    end
    function dy = dy(x, y, omega)
        dy = omega * x + 0.15 * y;
        return
    end
    function dz = dz(x, z)
        dz = 0.2 + z * (x - 10.0);
        return
    end
end
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace HomeOffice.Infrastructure.Persistence;

// Identity's store model is ready for HO-003. No users, login endpoints or schema are provisioned here.
public sealed class HomeOfficeDbContext(DbContextOptions<HomeOfficeDbContext> options)
    : IdentityDbContext<IdentityUser>(options);

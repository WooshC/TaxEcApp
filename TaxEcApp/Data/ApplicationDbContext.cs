using Microsoft.EntityFrameworkCore;
using TaxEC.Models;

namespace TaxEC.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Rol> Roles { get; set; }
        public DbSet<UsuarioRol> UsuarioRoles { get; set; }
        public DbSet<PerfilUsuario> PerfilesUsuario { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Usuario>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<UsuarioRol>()
                .HasIndex(ur => new { ur.UsuarioID, ur.RolID })
                .IsUnique();

            modelBuilder.Entity<PerfilUsuario>()
                .HasIndex(p => p.UsuarioID)
                .IsUnique();
        }
    }
}

using System;

namespace TaxEC.Models
{
    public class Usuario
    {
        public int UsuarioID { get; set; }
        public string NombreUsuario { get; set; }
        public string ContrasenaHash { get; set; }
        public string Email { get; set; }
        public string NombreCompleto { get; set; }
        public string Telefono { get; set; }
        public DateTime FechaRegistro { get; set; }
        public DateTime? UltimoAcceso { get; set; }
        public bool Activo { get; set; }
    }
}

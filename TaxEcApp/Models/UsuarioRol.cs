using System;

namespace TaxEC.Models
{
    public class UsuarioRol
    {
        public int UsuarioRolID { get; set; }
        public int UsuarioID { get; set; }
        public int RolID { get; set; }
        public DateTime FechaAsignacion { get; set; }
    }
}

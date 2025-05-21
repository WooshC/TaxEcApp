using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxEC.Models
{
    public class PerfilUsuario
    {
        [Key]
        public int PerfilID { get; set; }

        public int UsuarioID { get; set; }
        public int? ContribuyenteID { get; set; }

        public string? FotoPerfil { get; set; }
        public string? Biografia { get; set; }
        public string? Especialidad { get; set; }

        // Relaciones (opcional)
        public Usuario? Usuario { get; set; }
    }
}

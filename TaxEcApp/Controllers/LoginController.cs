using Microsoft.AspNetCore.Mvc;
using TaxEC.Data;
using TaxEC.Models;
using System.Security.Cryptography;
using System.Text;
using System.Linq;

namespace TaxEC.Controllers
{
    public class LoginController : Controller
    {
        private readonly ApplicationDbContext _context;

        public LoginController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Index(string nombreUsuario, string contrasena)
        {
            string hash = ObtenerSha256(contrasena);
            var usuario = _context.Usuarios
                .FirstOrDefault(u => u.NombreUsuario == nombreUsuario && u.ContrasenaHash == hash && u.Activo);

            if (usuario != null)
            {
                TempData["Bienvenida"] = $"Bienvenido, {usuario.NombreCompleto}";
                return RedirectToAction("Bienvenida");
            }

            ViewBag.Error = "Credenciales inválidas";
            return View();
        }

        public IActionResult Bienvenida()
        {
            ViewBag.Mensaje = TempData["Bienvenida"];
            return View();
        }

        private string ObtenerSha256(string texto)
        {
            using (SHA256 sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(texto));
                var sb = new StringBuilder();
                foreach (var b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
    }
}

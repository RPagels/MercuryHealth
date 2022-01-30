using Microsoft.AspNetCore.Mvc;

namespace MercuryHealth.Web.Controllers
{
    public class NutritionController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}

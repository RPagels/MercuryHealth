#nullable disable
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.Extensions.Options;

namespace MercuryHealth.Web.Controllers;

public class NutritionsController : Controller
{
    private readonly MercuryHealthWebContext _context;
    private readonly TelemetryClient telemetry;
    private readonly PageSettings _pageSettings;
    private readonly IConfiguration _configuration;

    public NutritionsController(MercuryHealthWebContext context, TelemetryClient telemetry, IConfiguration Configuration, IOptionsSnapshot<PageSettings> pageSettings)
    {
        _context = context;
        _pageSettings = pageSettings.Value;
        this.telemetry = telemetry;
        _configuration = Configuration;
    }

    // GET: Nutritions /  TEST
    public async Task<IActionResult> Index()
    {
        // Save App Configuration Dynamic Update Settings
        ViewData["FontSize"] = _pageSettings.FontSize;
        ViewData["FontColor"] = _pageSettings.FontColor;
        ViewData["BackgroundColor"] = _pageSettings.BackgroundColor;

        // Save App Configuration Dynamic Configuration Settings
        ViewData["Website_FontName"] = _configuration["WEBSITE_FONTNAME"];
        ViewData["Website_FontColor"] = _configuration["WEBSITE_FONTCOLOR"];
        ViewData["Website_FontSize"] = _configuration["WEBSITE_FONTSIZE"];

        // Keep color logic out of the ViewPage, per MVC pattern, use a ViewModel.
        var nutritions = from n in _context.Nutrition select n;

        List<NutritionViewModel> NutritionViewModels = new List<NutritionViewModel>();

        foreach (var mynutritionrec in nutritions)
        {
            NutritionViewModel nvm = new NutritionViewModel();

            nvm.Id = mynutritionrec.Id;
            nvm.Calories = mynutritionrec.Calories;
            nvm.CarbohydratesInGrams = mynutritionrec.CarbohydratesInGrams;
            nvm.Color = mynutritionrec.Color;
            nvm.Description = mynutritionrec.Description;
            nvm.FatInGrams = mynutritionrec.FatInGrams;
            nvm.MealTime = mynutritionrec.MealTime;
            nvm.ProteinInGrams = mynutritionrec.ProteinInGrams;
            nvm.Quantity = mynutritionrec.Quantity;
            nvm.SodiumInGrams = mynutritionrec.SodiumInGrams;
            nvm.Tags = mynutritionrec.Tags;
            nvm.FontColor = _pageSettings.FontColor; //"Black";

            // Check for text with API in it
            if (mynutritionrec.Tags == "API Update")
            {
                nvm.FontColor = "Red";
            }

            NutritionViewModels.Add(nvm);

        }

        // Application Insights - Track Events
        telemetry.TrackEvent("TrackEvent-Nutrition ViewModel Created");

        //return View(await _context.Nutrition.ToListAsync());
        return View(NutritionViewModels);
    }

    // GET: Nutritions/Details/5
    public async Task<IActionResult> Details(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var nutrition = await _context.Nutrition
            .FirstOrDefaultAsync(m => m.Id == id);
        if (nutrition == null)
        {
            return NotFound();
        }

        return View(nutrition);
    }

    // GET: Nutritions/Create
    public IActionResult Create()
    {
        return View();
    }

    // POST: Nutritions/Create
    // To protect from overposting attacks, enable the specific properties you want to bind to.
    // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create([Bind("Id,Description,Quantity,MealTime,Tags,Calories,ProteinInGrams,FatInGrams,CarbohydratesInGrams,SodiumInGrams,Color")] Nutrition nutrition)
    {
        if (ModelState.IsValid)
        {
            _context.Add(nutrition);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }
        return View(nutrition);
    }

    // GET: Nutritions/Edit/5
    public async Task<IActionResult> Edit(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var nutrition = await _context.Nutrition.FindAsync(id);
        if (nutrition == null)
        {
            return NotFound();
        }
        return View(nutrition);
    }

    // POST: Nutritions/Edit/5
    // To protect from overposting attacks, enable the specific properties you want to bind to.
    // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, [Bind("Id,Description,Quantity,MealTime,Tags,Calories,ProteinInGrams,FatInGrams,CarbohydratesInGrams,SodiumInGrams,Color")] Nutrition nutrition)
    {
        if (id != nutrition.Id)
        {
            return NotFound();
        }

        if (ModelState.IsValid)
        {
            try
            {
                _context.Update(nutrition);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!NutritionExists(nutrition.Id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }
            return RedirectToAction(nameof(Index));
        }
        return View(nutrition);
    }

    // GET: Nutritions/Delete/5
    public async Task<IActionResult> Delete(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var nutrition = await _context.Nutrition
            .FirstOrDefaultAsync(m => m.Id == id);
        if (nutrition == null)
        {
            return NotFound();
        }

        return View(nutrition);
    }

    // POST: Nutritions/Delete/5
    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var nutrition = await _context.Nutrition.FindAsync(id);
        _context.Nutrition.Remove(nutrition);
        await _context.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }

    private bool NutritionExists(int id)
    {
        return _context.Nutrition.Any(e => e.Id == id);
    }
}

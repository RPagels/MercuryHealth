#nullable disable
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.Extensions.Options;
using System.Configuration;

namespace MercuryHealth.Web.Controllers;

public class ExercisesController : Controller
{
    private readonly MercuryHealthWebContext _context;
    private readonly TelemetryClient telemetry;
    private readonly PageSettings _pageSettings;
    private readonly IConfiguration _configuration;

    public ExercisesController(MercuryHealthWebContext context, TelemetryClient telemetry, IConfiguration Configuration, IOptionsSnapshot<PageSettings> pageSettings)
    //public ExercisesController(MercuryHealthWebContext context, TelemetryClient telemetry)
    {
        _context = context;
        _pageSettings = pageSettings.Value;
        this.telemetry = telemetry;
        _configuration = Configuration;
    }

    // GET: Exercises
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

        //return View(await _context.Exercises.ToListAsync());
        // Keep color logic out of the ViewPage, per MVC pattern, use a ViewModel.
        var exercises = from n in _context.Exercises select n;

        List<ExercisesViewModel> ExerciseViewModels = new List<ExercisesViewModel>();

        foreach (var myexerciserec in exercises)
        {
            ExercisesViewModel evm = new ExercisesViewModel();

            evm.Id = myexerciserec.Id;
            evm.Name = myexerciserec.Name;
            evm.Description = myexerciserec.Description;
            evm.ExerciseTime = myexerciserec.ExerciseTime;
            evm.Description = myexerciserec.Description;
            evm.MusclesInvolved = myexerciserec.MusclesInvolved;
            evm.Equipment = myexerciserec.Equipment;
            evm.FontColor = _pageSettings.FontColor; //"Black";

            // Check for text with API in it
            if (myexerciserec.Equipment == "API Update")
            {
                evm.FontColor = "Red";
            }

            ExerciseViewModels.Add(evm);

        }

        // Application Insights - Track Events
        telemetry.TrackEvent("TrackEvent-Exercise ViewModel Created");

        //return View(await _context.Nutrition.ToListAsync());
        return View(ExerciseViewModels);
    }

    // GET: Exercises/Details/5
    public async Task<IActionResult> Details(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var exercises = await _context.Exercises
            .FirstOrDefaultAsync(m => m.Id == id);
        if (exercises == null)
        {
            return NotFound();
        }

        return View(exercises);
    }

    // GET: Exercises/Create
    public IActionResult Create()
    {
        return View();
    }

    // POST: Exercises/Create
    // To protect from overposting attacks, enable the specific properties you want to bind to.
    // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create([Bind("Id,Name,Description,ExerciseTime,MusclesInvolved,Equipment")] Exercises exercises)
    {
        if (ModelState.IsValid)
        {
            _context.Add(exercises);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }
        return View(exercises);
    }

    // GET: Exercises/Edit/5
    public async Task<IActionResult> Edit(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var exercises = await _context.Exercises.FindAsync(id);
        if (exercises == null)
        {
            return NotFound();
        }
        return View(exercises);
    }

    // POST: Exercises/Edit/5
    // To protect from overposting attacks, enable the specific properties you want to bind to.
    // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, [Bind("Id,Name,Description,ExerciseTime,MusclesInvolved,Equipment")] Exercises exercises)
    {
        if (id != exercises.Id)
        {
            return NotFound();
        }

        if (ModelState.IsValid)
        {
            try
            {
                _context.Update(exercises);
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ExercisesExists(exercises.Id))
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
        return View(exercises);
    }

    // GET: Exercises/Delete/5
    public async Task<IActionResult> Delete(int? id)
    {
        if (id == null)
        {
            return NotFound();
        }

        var exercises = await _context.Exercises
            .FirstOrDefaultAsync(m => m.Id == id);
        if (exercises == null)
        {
            return NotFound();
        }

        return View(exercises);
    }

    // POST: Exercises/Delete/5
    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var exercises = await _context.Exercises.FindAsync(id);
        _context.Exercises.Remove(exercises);
        await _context.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }

    private bool ExercisesExists(int id)
    {
        return _context.Exercises.Any(e => e.Id == id);
    }
}

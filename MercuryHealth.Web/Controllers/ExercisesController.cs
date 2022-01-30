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

namespace MercuryHealth.Web.Controllers
{
    public class ExercisesController : Controller
    {
        private readonly MercuryHealthWebContext _context;

        public ExercisesController(MercuryHealthWebContext context)
        {
            _context = context;
        }

        // GET: Exercises
        public async Task<IActionResult> Index()
        {
            return View(await _context.Exercises.ToListAsync());
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
}

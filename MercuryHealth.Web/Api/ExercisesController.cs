using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace MercuryHealth.Web.Api;

[Route("api/[controller]")]
[ApiController]
public class ExercisesController : ControllerBase
{
    private readonly MercuryHealthWebContext _context;
    private readonly TelemetryClient telemetry;

    public ExercisesController(MercuryHealthWebContext context, TelemetryClient telemetry)
    {
        _context = context;
        this.telemetry = telemetry;
    }

    // GET: api/Exercises
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Exercises>>> GetExercises()
    {
        return await _context.Exercises.ToListAsync();
    }

    // GET: api/Exercises/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Exercises>> GetExercises(int id)
    {
        var exercises = await _context.Exercises.FindAsync(id);

        if (exercises == null)
        {
            return NotFound();
        }

        return Ok(exercises);
    }

    // PUT: api/Exercises/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutExercises(int id, Exercises exercises)
    {
        if (id != exercises.Id)
        {
            return BadRequest();
        }

        _context.Entry(exercises).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!ExercisesExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // POST: api/Exercises
    [HttpPost]
    public async Task<ActionResult<Exercises>> PostExercises(Exercises exercises)
    {
        _context.Exercises.Add(exercises);
        await _context.SaveChangesAsync();

        return CreatedAtAction("GetExercises", new { id = exercises.Id }, exercises);
    }

    // DELETE: api/Exercises/5
    [HttpDelete("{id}")]
    public async Task<ActionResult<Exercises>> DeleteExercises(int id)
    {
        var exercises = await _context.Exercises.FindAsync(id);
        if (exercises == null)
        {
            return NotFound();
        }

        _context.Exercises.Remove(exercises);
        await _context.SaveChangesAsync();

        return Ok(exercises);
    }

    private bool ExercisesExists(int id)
    {
        return _context.Exercises.Any(e => e.Id == id);
    }
}

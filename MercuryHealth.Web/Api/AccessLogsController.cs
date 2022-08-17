using MercuryHealth.Web.Data;
using MercuryHealth.Web.Models;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace MercuryHealth.Web.Api;

[Route("api/[controller]")]
[ApiController]
public class AccessLogsController : ControllerBase
{
    private readonly MercuryHealthWebContext _context;
    private readonly TelemetryClient telemetry;

    public AccessLogsController(MercuryHealthWebContext context, TelemetryClient telemetry)
    {
        _context = context;
        this.telemetry = telemetry;
    }

    // GET: api/<AccessLogsController>
    [HttpGet(Name = "GetAccessLogs")]
    //[HttpGet]
    public async Task<ActionResult<IEnumerable<AccessLogs>>> GetAccessLogs()
    {
        return await _context.AccessLogs.ToListAsync();
    }

    // GET: api/AccessLogs/5
    [HttpGet("{id}")]
    public async Task<ActionResult<AccessLogs>> GetAccessLogs(int id)
    {
        var accesslogs = await _context.AccessLogs.FindAsync(id);

        if (accesslogs == null)
        {
            return NotFound();
        }

        // Application Insights - Track Events
        telemetry.TrackEvent("TrackEvent-Nutrition Item API(GET) " + accesslogs.Id.ToString() + " " + accesslogs.PageName);

        return Ok(accesslogs);
    }

    // PUT: api/Nutritions/5
    //[HttpPut("{id}")]
    //public async Task<IActionResult> PutNutrition(int id, Nutrition nutrition)
    //{
    //    if (id != nutrition.Id)
    //    {
    //        return BadRequest();
    //    }

    //    _context.Entry(nutrition).State = EntityState.Modified;

    //    try
    //    {

    //        // Application Insights - Track Events
    //        telemetry.TrackEvent("TrackEvent-Nutrition Item API(PUT) " + nutrition.Id.ToString() + " " + nutrition.Description);

    //        await _context.SaveChangesAsync();
    //    }
    //    catch (DbUpdateConcurrencyException)
    //    {
    //        if (!NutritionExists(id))
    //        {
    //            return NotFound();
    //        }
    //        else
    //        {
    //            //telemetry.TrackException(DbUpdateConcurrencyException);
    //            throw;
    //        }
    //    }

    //    return NoContent();
    //}

    // POST: api/AccessLogs
    //[HttpPost]
    //public async Task<ActionResult<AccessLogs>> PostNutrition(Nutrition nutrition)
    //{
    //    _context.Nutrition.Add(nutrition);
    //    await _context.SaveChangesAsync();

    //    // Application Insights - Track Events
    //    telemetry.TrackEvent("TrackEvent-Nutrition Item API(POST) " + nutrition.Id.ToString() + " " + nutrition.Description);

    //    return CreatedAtAction("GetNutrition", new { id = nutrition.Id }, nutrition);
    //}

    // DELETE: api/Nutritions/5
    //[HttpDelete("{id}")]
    //public async Task<ActionResult<Nutrition>> DeleteNutrition(int id)
    //{
    //    var nutrition = await _context.Nutrition.FindAsync(id);
    //    if (nutrition == null)
    //    {
    //        return NotFound();
    //    }

    //    _context.Nutrition.Remove(nutrition);
    //    await _context.SaveChangesAsync();

    //    // Application Insights - Track Events
    //    telemetry.TrackEvent("TrackEvent-Nutrition Item API(DELETE) " + nutrition.Id.ToString() + " " + nutrition.Description);

    //    return Ok(nutrition);
    //}

    //private bool NutritionExists(int id)
    //{
    //    return _context.Nutrition.Any(e => e.Id == id);
    //}
}

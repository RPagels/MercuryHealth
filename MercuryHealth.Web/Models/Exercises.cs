using System.ComponentModel;
//using System.ComponentModel.DataAnnotations;

namespace MercuryHealth.Web.Models;

public class Exercises
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? Description { get; set; }

    [DisplayName("Exercise Time")]
    //[RegularExpression(@"${day}-${month}-${year}")]
    public DateTime ExerciseTime { get; set; }

    [DisplayName("Muscles")]
    public string? MusclesInvolved { get; set; }

    public string? Equipment { get; set; }
}

public class ExercisesViewModel
{
    public int Id { get; set; }

    public string? Name { get; set; }

    public string? Description { get; set; }

    [DisplayName("Exercise Time")]
    public DateTime ExerciseTime { get; set; }

    [DisplayName("Muscles")]
    public string? MusclesInvolved { get; set; }

    public string? Equipment { get; set; }
    public string? FontColor { get; set; }
}
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace MercuryHealth.Web.Models;

public class Nutrition
{
    public int Id { get; set; }

    public string? Description { get; set; }

    public float Quantity { get; set; }

    [DisplayName("Meal Time")]
    public DateTime MealTime { get; set; }

    public string? Tags { get; set; }

    public int Calories { get; set; }

    [DisplayName("Protein/g")]
    [DisplayFormat(DataFormatString = "{0:N}", ApplyFormatInEditMode = true)]
    [RegularExpression(@"^[\d,]+(\.\d{1,5})?$", ErrorMessage = "Must be formated 9.99999")]
    public decimal ProteinInGrams { get; set; }

    [DisplayName("Fat/g")]
    [DisplayFormat(DataFormatString = "{0:N}", ApplyFormatInEditMode = true)]
    public decimal FatInGrams { get; set; }

    [DisplayName("Carbohydrates/g")]
    [DisplayFormat(DataFormatString = "{0:N}", ApplyFormatInEditMode = true)]
    public decimal CarbohydratesInGrams { get; set; }

    [DisplayName("Sodium/g")]
    [DisplayFormat(DataFormatString = "{0:N}", ApplyFormatInEditMode = true)]
    public decimal SodiumInGrams { get; set; }

    [DisplayName("Color")]
    public string? Color { get; set; }
}

public class NutritionViewModel
{
    public int Id { get; set; }

    public string? Description { get; set; }

    public float Quantity { get; set; }

    [DisplayName("Meal Time")]
    public DateTime MealTime { get; set; }

    public string? Tags { get; set; }

    public int Calories { get; set; }

    [DisplayName("Protein/g")]
    [DisplayFormat(DataFormatString = "{0:N}")]
    public decimal ProteinInGrams { get; set; }

    [DisplayName("Fat/g")]
    [DisplayFormat(DataFormatString = "{0:N}")]
    public decimal FatInGrams { get; set; }

    [DisplayName("Carbohydrates/g")]
    [DisplayFormat(DataFormatString = "{0:N}")]
    public decimal CarbohydratesInGrams { get; set; }

    [DisplayName("Sodium/g")]
    [DisplayFormat(DataFormatString = "{0:N}")]
    public decimal SodiumInGrams { get; set; }

    [DisplayName("Color")]
    public string? Color { get; set; }

    public string? FontColor { get; set; }
}

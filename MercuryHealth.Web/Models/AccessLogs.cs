using System.ComponentModel.DataAnnotations;

namespace MercuryHealth.Web.Models;

public class AccessLogs
{
    public int Id { get; set; }

    public string? PageName { get; set; }

    //[DisplayFormat(DataFormatString = "{0:dddd, MMM d, yyyy}")]
    [DisplayFormat(DataFormatString = "{0:f}")]
    public DateTime AccessDate { get; set; }

    [DisplayFormat(DataFormatString = "{0:N0}")]
    public int Visits { get; set; }

}

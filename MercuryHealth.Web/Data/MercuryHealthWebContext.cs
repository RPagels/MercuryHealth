#nullable disable
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MercuryHealth.Web.Models;

namespace MercuryHealth.Web.Data
{
    public class MercuryHealthWebContext : DbContext
    {
        public MercuryHealthWebContext (DbContextOptions<MercuryHealthWebContext> options)
            : base(options)
        {
        }

        public DbSet<MercuryHealth.Web.Models.Nutrition> Nutrition { get; set; }

        public DbSet<MercuryHealth.Web.Models.Exercises> Exercises { get; set; }

        public DbSet<MercuryHealth.Web.Models.AccessLogs> AccessLogs { get; set; }

    }
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Kiosco.API.Filters;

public class KioskAuthFilter : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        if (!context.HttpContext.Request.Headers.TryGetValue("X-Device-UUID", out var deviceUuid))
        {
            context.Result = new BadRequestObjectResult(new 
            { 
                Title = "Error de Autenticación Kiosco",
                Status = 400,
                Detail = "El encabezado X-Device-UUID es obligatorio para la App Móvil." 
            });
            return;
        }

        if (!Guid.TryParse(deviceUuid, out _))
        {
            context.Result = new BadRequestObjectResult(new 
            { 
                Title = "Formato Inválido",
                Status = 400,
                Detail = "X-Device-UUID debe ser un GUID válido." 
            });
            return;
        }

        base.OnActionExecuting(context);
    }
}

using System.Net;

namespace Kiosco.Domain.Exceptions;

public abstract class KioscoBaseException : Exception
{
    public HttpStatusCode StatusCode { get; }
    public string ErrorCode { get; }

    protected KioscoBaseException(string message, HttpStatusCode statusCode, string errorCode) : base(message)
    {
        StatusCode = statusCode;
        ErrorCode = errorCode;
    }
}

public class BusinessRuleException : KioscoBaseException
{
    public BusinessRuleException(string message, string errorCode = "BUSINESS_RULE_VIOLATION") 
        : base(message, HttpStatusCode.BadRequest, errorCode) { }
}

public class ResourceNotFoundException : KioscoBaseException
{
    public ResourceNotFoundException(string resourceName, object key) 
        : base($"{resourceName} con ID '{key}' no fue encontrado.", HttpStatusCode.NotFound, "RESOURCE_NOT_FOUND") { }
}

public class ValidationException : KioscoBaseException
{
    public ValidationException(string message) 
        : base(message, HttpStatusCode.BadRequest, "VALIDATION_ERROR") { }
}

public class IntegrityException : KioscoBaseException
{
    public IntegrityException(string message) 
        : base(message, HttpStatusCode.BadRequest, "DATA_INTEGRITY_ERROR") { }
}

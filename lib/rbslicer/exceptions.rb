# coding: utf-8

module Exceptions
  class SlicingDiceException < StandardError; end
  
  class MissingParamError < StandardError; end

  class SlicingDiceHTTPError < SlicingDiceException; end

  class FieldCreateInternalException < SlicingDiceException; end
  
  # CLIENT API ERRORS
  class EmptyParameterException < StandardError; end

  class InvalidSlicingDiceKeyException < StandardError; end

  class WrongTypeException < StandardError; end

  class InvalidIndexException < StandardError; end

  class DatabaseOperationException < StandardError; end

  class InvalidQueryTypeException < StandardError; end

  class InvalidFieldTypeException < StandardError; end

  class InvalidFieldException < StandardError; end

  class InvalidFieldNameException < StandardError; end

  class InvalidFieldDescriptionException < StandardError; end

  class MaxLimitException < StandardError; end

  class InvalidQueryException < StandardError; end

  class SlicingDiceKeysException < StandardError; end

  # Authentication and Authorization
  class AuthMissingHeaderException < SlicingDiceException; end

  class AuthAPIKeyException < SlicingDiceException; end

  class AuthInvalidAPIKeyException < SlicingDiceException; end

  class AuthIncorrectPermissionException < SlicingDiceException; end

  class AuthInvalidRemoteException < SlicingDiceException; end

  class CustomKeyInvalidFieldCreationException < SlicingDiceException; end

  class CustomKeyInvalidPermissionForFieldException < SlicingDiceException; end

  class CustomKeyInvalidOperationException < SlicingDiceException; end

  class CustomKeyNotPermittedException < SlicingDiceException; end

  class CustomKeyRouteNotPermittedException < SlicingDiceException; end

  class DemoApiInvalidEndpointException < SlicingDiceException; end

  # INTERNAL ERRORS
  class InternalServerException < SlicingDiceException; end

  # REQUEST VALIDATIONS ERRORS
  class RequestMissingContentTypeException < SlicingDiceException; end

  class RequestIncorrectContentTypeValueException < SlicingDiceException; end

  class RequestRateLimitException < SlicingDiceException; end

  class RequestInvalidJsonException < SlicingDiceException; end

  class RequestInvalidHttpMethodException < SlicingDiceException; end

  class RequestInvalidEndpointException < SlicingDiceException; end

  class RequestIncorrectHttpException < SlicingDiceException; end

  class RequestExceedLimitException < SlicingDiceException; end

  # ACCOUNT ERRORS
  class AccountMissingPaymentMethodException < SlicingDiceException; end

  class AccountPaymentRequiredException < SlicingDiceException; end

  class AccountBannedException < SlicingDiceException; end

  class AccountDisabledException < SlicingDiceException; end

  # FIELD API ERRORS
  class FieldMissingParamException < SlicingDiceException; end

  class FieldTypeException < SlicingDiceException; end

  class FieldIntegerValuesException < SlicingDiceException; end

  class FieldAlreadyExistsException < SlicingDiceException; end

  class FieldLimitException < SlicingDiceException; end

  class FieldTimeSeriesLimitException < SlicingDiceException; end

  class FieldTimeSeriesSystemLimitException < SlicingDiceException; end

  class FieldDecimalTypeException < SlicingDiceException; end

  class FieldStorageValueException < SlicingDiceException; end

  class FieldInvalidApiName < SlicingDiceException; end

  class FieldInvalidNameException < SlicingDiceException; end

  class FieldInvalidDescriptionException < SlicingDiceException; end

  class FieldExceedDescriptionlengthException < SlicingDiceException; end

  class FieldInvalidCardinalityException < SlicingDiceException; end

  class FieldDecimalLimitException < SlicingDiceException; end

  class FieldRangeLimitException < SlicingDiceException; end

  class FieldExceededMaxNameLenghtException < SlicingDiceException; end

  class FieldExceededMaxApiNameLenghtException < SlicingDiceException; end

  class FieldEmptyEntityIdException < SlicingDiceException; end

  class FieldExceededPermitedValueException < SlicingDiceException; end

  class FieldInvalidApiNameException < SlicingDiceException; end

  # INDEX API ERRORS
  class IndexInvalidDecimalPlacesException < SlicingDiceException; end

  class IndexEntityValueTypeException < SlicingDiceException; end

  class IndexFieldNameTypeException < SlicingDiceException; end

  class IndexFieldTypeException < SlicingDiceException; end

  class IndexEntityNameTooBigException < SlicingDiceException; end

  class IndexFieldValueTooBigException < SlicingDiceException; end

  class IndexTimeSeriesDateFormatException < SlicingDiceException; end

  class IndexFieldNotActiveException < SlicingDiceException; end

  class IndexLimitException < SlicingDiceException; end

  class IndexIdLimitException < SlicingDiceException; end

  class IndexFieldLimitException < SlicingDiceException; end

  class IndexDateFormatException < SlicingDiceException; end

  class IndexFieldStringEmptyValueException < SlicingDiceException; end

  class IndexFieldTimeseriesInvalidParameterException < SlicingDiceException; end

  class IndexFieldNumericInvalidValueException < SlicingDiceException; end

  class IndexFieldTimeseriesMissingValueException < SlicingDiceException; end

  class QueryTimeSeriesInvalidPrecisionSecondsException < SlicingDiceException; end

  class QueryTimeSeriesInvalidPrecisionMinutesException < SlicingDiceException; end

  class QueryTimeSeriesInvalidPrecisionHoursException < SlicingDiceException; end

  class QueryDateFormatException < SlicingDiceException; end

  class QueryRelativeIntervalException < SlicingDiceException; end

  # QUERY API ERRORS
  class QueryMissingQueryException < SlicingDiceException; end

  class QueryInvalidTypeException < SlicingDiceException; end

  class QueryMissingTypeParamException < SlicingDiceException; end

  class QueryInvalidOperatorException < SlicingDiceException; end

  class QueryIncorrectOperatorUsageException < SlicingDiceException; end

  class QueryFieldNotActiveException < SlicingDiceException; end

  class QueryMissingOperatorException < SlicingDiceException; end

  class QueryIncompleteException < SlicingDiceException; end

  class QueryEventCountQueryException < SlicingDiceException; end

  class QueryInvalidMetricException < SlicingDiceException; end

  class QueryIntegerException < SlicingDiceException; end

  class QueryFieldLimitException < SlicingDiceException; end

  class QueryLevelLimitException < SlicingDiceException; end

  class QueryBadAggsFormationException < SlicingDiceException; end

  class QueryMetricsLevelException < SlicingDiceException; end

  class QueryTimeSeriesException < SlicingDiceException; end

  class QueryInvalidAggFilterException < SlicingDiceException; end

  class QueryMetricsTypeException < SlicingDiceException; end

  class QueryContainsNumericException < SlicingDiceException; end

  class QueryExistsEntityLimitException < SlicingDiceException; end

  class QueryMultipleFiltersException < SlicingDiceException; end

  class QueryMissingNameParamException < SlicingDiceException; end

  class QuerySavedAlreadyExistsException < SlicingDiceException; end

  class QuerySavedNotExistsException < SlicingDiceException; end

  class QuerySavedInvalidTypeException < SlicingDiceException; end

  class MethodNotAllowedException < SlicingDiceException; end

  class QueryExistsMissingIdsException < SlicingDiceException; end

  class QueryInvalidFormatException < SlicingDiceException; end

  class QueryTopValuesParameterEmptyException < SlicingDiceException; end

  class QueryDataExtractionLimitValueException < SlicingDiceException; end

  class QueryDataExtractionLimitValueTooBigException < SlicingDiceException; end

  class QueryDataExtractionLimitAndPageTokenValueException < SlicingDiceException; end

  class QueryDataExtractionPageTokenValueException < SlicingDiceException; end

  class QueryDataExtractionFieldLimitException < SlicingDiceException; end

  class QueryExistsEntityEmptyException < SlicingDiceException; end

  class QuerySavedInvalidQueryValueException < SlicingDiceException; end

  class QuerySavedInvalidCachePeriodValueException < SlicingDiceException; end

  class QuerySavedInvalidNameException < SlicingDiceException; end

  class QueryCountInvalidParameterErrorException < SlicingDiceException; end

  class QueryAggregationInvalidParameterException < SlicingDiceException; end

  class QueryAggregationInvalidFilterQueryException < SlicingDiceException; end

  class QueryInvalidMinfreqException < SlicingDiceException; end

  class QueryExceededMaxNumberQuerysException < SlicingDiceException; end

  class QueryInvalidOperatorUsageException < SlicingDiceException; end

  class QueryInvalidParameterUsageException < SlicingDiceException; end

  class QueryParameterInvalidFieldUsageException < SlicingDiceException; end

  class QueryInvalidFieldUsageException < SlicingDiceException; end

  class FieldInvalidRangeException < SlicingDiceException; end

end

# coding: utf-8

module Exceptions
  class SlicingDiceException < StandardError; end
  
  class MissingParamError < StandardError; end

  class SlicingDiceHTTPError < SlicingDiceException; end

  class ColumnCreateInternalException < SlicingDiceException; end
  
  # CLIENT API ERRORS
  class EmptyParameterException < StandardError; end

  class InvalidSlicingDiceKeyException < StandardError; end

  class WrongTypeException < StandardError; end

  class InvalidInsertException < StandardError; end

  class DatabaseOperationException < StandardError; end

  class InvalidQueryTypeException < StandardError; end

  class InvalidColumnTypeException < StandardError; end

  class InvalidColumnException < StandardError; end

  class InvalidColumnNameException < StandardError; end

  class InvalidColumnDescriptionException < StandardError; end

  class MaxLimitException < StandardError; end

  class InvalidQueryException < StandardError; end

  class SlicingDiceKeysException < StandardError; end

  # Authentication and Authorization
  class AuthMissingHeaderException < SlicingDiceException; end

  class AuthAPIKeyException < SlicingDiceException; end

  class AuthInvalidAPIKeyException < SlicingDiceException; end

  class AuthIncorrectPermissionException < SlicingDiceException; end

  class AuthInvalidRemoteException < SlicingDiceException; end

  class CustomKeyInvalidColumnCreationException < SlicingDiceException; end

  class CustomKeyInvalidPermissionForColumnException < SlicingDiceException; end

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

  class RequestExceededLimitException < SlicingDiceException; end

  # ACCOUNT ERRORS
  class AccountMissingPaymentMethodException < SlicingDiceException; end

  class AccountPaymentRequiredException < SlicingDiceException; end

  class AccountBannedException < SlicingDiceException; end

  class AccountDisabledException < SlicingDiceException; end

  # COLUMN API ERRORS
  class ColumnMissingParamException < SlicingDiceException; end

  class ColumnTypeException < SlicingDiceException; end

  class ColumnIntegerValuesException < SlicingDiceException; end

  class ColumnAlreadyExistsException < SlicingDiceException; end

  class ColumnLimitException < SlicingDiceException; end

  class ColumnTimeSeriesLimitException < SlicingDiceException; end

  class ColumnTimeSeriesSystemLimitException < SlicingDiceException; end

  class ColumnDecimalTypeException < SlicingDiceException; end

  class ColumnStorageValueException < SlicingDiceException; end

  class ColumnInvalidApiName < SlicingDiceException; end

  class ColumnInvalidNameException < SlicingDiceException; end

  class ColumnInvalidDescriptionException < SlicingDiceException; end

  class ColumnExceededDescriptionlengthException < SlicingDiceException; end

  class ColumnInvalidCardinalityException < SlicingDiceException; end

  class ColumnDecimalLimitException < SlicingDiceException; end

  class ColumnRangeLimitException < SlicingDiceException; end

  class ColumnExceededMaxNameLenghtException < SlicingDiceException; end

  class ColumnExceededMaxApiNameLenghtException < SlicingDiceException; end

  class ColumnEmptyEntityIdException < SlicingDiceException; end

  class ColumnExceededPermitedValueException < SlicingDiceException; end

  class ColumnInvalidApiNameException < SlicingDiceException; end

  # INSERTION API ERRORS
  class InsertInvalidDecimalPlacesException < SlicingDiceException; end

  class InsertEntityValueTypeException < SlicingDiceException; end

  class InsertColumnNameTypeException < SlicingDiceException; end

  class InsertColumnTypeException < SlicingDiceException; end

  class InsertEntityNameTooBigException < SlicingDiceException; end

  class InsertColumnValueTooBigException < SlicingDiceException; end

  class InsertTimeSeriesDateFormatException < SlicingDiceException; end

  class InsertColumnNotActiveException < SlicingDiceException; end

  class InsertLimitException < SlicingDiceException; end

  class InsertIdLimitException < SlicingDiceException; end

  class InsertColumnLimitException < SlicingDiceException; end

  class InsertDateFormatException < SlicingDiceException; end

  class InsertColumnStringEmptyValueException < SlicingDiceException; end

  class InsertColumnTimeSeriesInvalidParameterException < SlicingDiceException; end

  class InsertColumnNumericInvalidValueException < SlicingDiceException; end

  class InsertColumnTimeSeriesMissingValueException < SlicingDiceException; end

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

  class QueryColumnNotActiveException < SlicingDiceException; end

  class QueryMissingOperatorException < SlicingDiceException; end

  class QueryIncompleteException < SlicingDiceException; end

  class QueryEventCountQueryException < SlicingDiceException; end

  class QueryInvalidMetricException < SlicingDiceException; end

  class QueryIntegerException < SlicingDiceException; end

  class QueryColumnLimitException < SlicingDiceException; end

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

  class QueryDataExtractionColumnLimitException < SlicingDiceException; end

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

  class QueryParameterInvalidColumnUsageException < SlicingDiceException; end

  class QueryInvalidColumnUsageException < SlicingDiceException; end

  class InsertInvalidRangeException < SlicingDiceException; end

end

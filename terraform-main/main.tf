#1 - Create S3 bucket to store the scripts
#2 - Store the python code
#3 - Store the lambda code
#4 - Create the Glue
#5 - Create the Glue Job
#6 - Create the Lambda

#https://registry.terraform.io/search/modules?namespace=terraform-aws-modules

resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
}

locals {
  project_name = "${var.app_name}-${random_string.random.result}-${var.environment}"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${local.project_name}-bucket"
  tags = {
    Engine      = "Terraform"
    Environment = var.environment
  }
}

data "archive_file" "zip_dir" {
  count       = length(var.zip_files)
  type        = "zip"
  source_dir  = var.zip_files[count.index]["location"]
  output_path = var.zip_files[count.index]["output"]
}

module "save_object" {
  count       = length(var.s3_object_list)
  source      = "./modules/bucket/save-data"
  bucket_name = module.s3_bucket.s3_bucket_id
  key_object  = var.s3_object_list[count.index]["key"]
  path_file   = var.s3_object_list[count.index]["file_location"]
}

module "iam" {
  source   = "./modules/iam"
  iam_name = local.project_name
  tags = {
    Engine      = "Terraform"
    Environment = var.environment
  }
}

module "lambda_function_existing_package_s3" {
  depends_on = [
    module.save_object,
    module.iam
  ]
  count  = length(var.s3_lambda_functions)
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.project_name}-${var.s3_lambda_functions[count.index]["name"]}"
  handler       = var.s3_lambda_functions[count.index]["handler"]
  runtime       = var.s3_lambda_functions[count.index]["runtime"]

  create_package = false
  s3_existing_package = {
    bucket = module.s3_bucket.s3_bucket_id
    key    = var.s3_lambda_functions[count.index]["key"]
  }
  tags        = var.tags
  lambda_role = module.iam.arn
}

###########

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = local.project_name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_cloudwatch_log_group" "hello_world" {
#   name = "/aws/lambda/${local.project_name}-${var.s3_lambda_functions[0]["name"]}"

#   retention_in_days = 30
# }

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = module.lambda_function_existing_package_s3[0].lambda_function_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${local.project_name}-${var.s3_lambda_functions[0]["name"]}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

# resource "aws_apigatewayv2_stage" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   name        = "serverless_lambda_stage"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_gw.arn

#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }
# }

# resource "aws_apigatewayv2_integration" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   integration_uri    = module.lambda_function_existing_package_s3[0].lambda_function_invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
# }

# resource "aws_apigatewayv2_route" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   route_key = "GET /hello"
#   target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
# }

# resource "aws_cloudwatch_log_group" "api_gw" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

#   retention_in_days = 30
# }

# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = "${local.project_name}-${var.s3_lambda_functions[0]["name"]}"
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
# }

######

# resource "aws_lambda_permission" "apigw_lambda" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = "${local.project_name}-${var.s3_lambda_functions[0]["name"]}"
#   principal     = "apigateway.amazonaws.com"

#   # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#   source_arn = "arn:aws:execute-api:${var.region}:744380458397:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
# }

# # API Gateway
# resource "aws_api_gateway_rest_api" "api" {
#   name = "${local.project_name}-api-gateway"
# }

# #Each path will have his own method and integration

# resource "aws_api_gateway_resource" "resource" {
#   path_part   = "resource"
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   rest_api_id = aws_api_gateway_rest_api.api.id
# }

# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.resource.id
#   http_method             = aws_api_gateway_method.method.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = module.lambda_function_existing_package_s3[0].lambda_function_invoke_arn
# }

# output "test" {
#   value = module.lambda_function_existing_package_s3
# }

# resource "aws_api_gateway_deployment" "main" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = "main"
# }

# resource "aws_api_gateway_stage" "example" {
#   deployment_id = aws_api_gateway_deployment.api.id
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   stage_name    = "example"
# }

# resource "aws_api_gateway_method_settings" "example" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = aws_api_gateway_stage.api.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled = true
#     logging_level   = "INFO"
#   }
# }
# module "api_gateway" {
#   source = "terraform-aws-modules/apigateway-v2/aws"
#   name          = "${local.project_name}-api-gateway"
#   description   = "My awesome HTTP API Gateway"
#   protocol_type = "HTTP"
#   cors_configuration = {
#     allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
#     allow_methods = ["*"]
#     allow_origins = ["*"]
#   }

#   domain_name                 = "terraform-aws-modules.modules.tf"
#   domain_name_certificate_arn = "arn:aws:acm:eu-west-1:052235179155:certificate/2b3a7ed9-05e1-4f9e-952b-27744ba06da6"

#   integrations = {
#     "GET /" = {
#       lambda_arn = module.lambda_function_existing_package_s3[0].lambda_function_arn
#       timeout_milliseconds   = 12000
#     }
#   }
# }


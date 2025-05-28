data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/files/${var.function_name}.zip"
}

# Utilise un rôle existant
data "aws_iam_role" "lab_role" {
  name = "LabRole"  # Ou un autre rôle disponible dans ton environnement AWS Academy
}

# Une seule ressource Lambda
resource "aws_lambda_function" "lambda" {
  function_name = "${var.project_name}-${var.function_name}-${var.environment}"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  role          = data.aws_iam_role.lab_role.arn  # Utilise le rôle existant

  environment {
    variables = var.environment_variables
  }
}

#Creates the Cloud Watch Log Group
resource "aws_cloudwatch_log_group" "demo_flow_log_group" {
  name = "demo_flow-log-group"
}

#Creates the flow log IAM policy with specific actions
resource "aws_iam_policy" "demo_flow_log_policy" {
  name = "demo_flow_log_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = aws_cloudwatch_log_group.demo_flow_log_group.arn
      }
    ]
  })
  depends_on = [aws_cloudwatch_log_group.demo_flow_log_group]
}

#Creates the flow log IAM role with specific actions
resource "aws_iam_role" "demo_flow_log_role" {
  name = "demo_flow_log_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
#Ataches the IAM policy into the IAM role
resource "aws_iam_role_policy_attachment" "flow_log_role_policy" {
  policy_arn = aws_iam_policy.demo_flow_log_policy.arn
  role = aws_iam_role.demo_flow_log_role.name
}

#Configures the VPC flow log
resource "aws_flow_log" "demo_flow_log" {
  iam_role_arn = aws_iam_role.demo_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.demo_flow_log_group.arn
  traffic_type = "ALL"
  vpc_id = aws_vpc.demo-foundations-vpc.id

  depends_on = [aws_iam_role.demo_flow_log_role]
}
# 1.Define a CloudWatch Logs group using Terraform:
resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "/ecs/my_log_group"
}

# 2.Define a CloudWatch Logs stream using Terraform:
resource "aws_cloudwatch_log_stream" "my_log_stream_client" {
  name           = "my_log_stream_client"
  log_group_name = aws_cloudwatch_log_group.my_log_group.name
}

resource "aws_cloudwatch_log_stream" "my_log_stream_service" {
  name           = "my_log_stream_service"
  log_group_name = aws_cloudwatch_log_group.my_log_group.name
}

# 3.Modify your ECS Task Definition to include a log configuration that sends logs to the CloudWatch Logs stream defined in step 2:
# resource "aws_ecs_task_definition" "my_task_definition" {
#   # ...
#   container_definitions = jsonencode([
#     {
#       # ...
    #   "logConfiguration": {
    #     "logDriver": "awslogs",
    #     "options": {
    #       "awslogs-group": "/ecs/my_log_group",
    #       "awslogs-stream-prefix": "my_log_stream",
    #       "awslogs-region": "${var.aws_region}"
    #     }
    #   }
#     }
#   ])
# }

# 4.Create an IAM policy that allows the ECS task to write logs to CloudWatch Logs:
# resource "aws_iam_policy" "my_policy" {
#   name_prefix = "my_policy"
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         "Resource": [
#           "${aws_cloudwatch_log_group.my_log_group.arn}:*"
#         ]
#       }
#     ]
#   })
# }

# 5.Attach the IAM policy to your ECS Task Role:
# resource "aws_iam_role_policy_attachment" "my_role_policy_attachment" {
#   policy_arn = aws_iam_policy.my_policy.arn
#   role       = aws_iam_role.my_task_role.name
# }
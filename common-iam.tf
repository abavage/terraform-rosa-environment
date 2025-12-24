resource "aws_iam_role" "ec2_system_manager_instance_role" {
  name = "ec2-system-manager-instance-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "",
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_system_manager_instance_role_attachment" {
  role       = aws_iam_role.ec2_system_manager_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_role" {
  name = "ec2-system-manager-instance-role"
  role = aws_iam_role.ec2_system_manager_instance_role.name
}


resource "aws_iam_policy" "vpcflowlogs_cloudwatch" {

  name        = "VPCFlowLogs-Cloudwatch"
  path        = "/"
  description = "Core Flow Log"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:log-group:*:log-stream:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:log-group:*"
      },
      {
        "Effect" : "Allow",
        "Action" : "logs:DescribeLogGroups",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "vpcflowlogs_cloudwatch" {

  name = "VPCFlowLogs-Cloudwatch"
  # permissions_boundary = local.permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "vpc-flow-logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.id}"
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:vpc-flow-log/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpcflowlogs_cloudwatch_attachment" {
  role       = aws_iam_role.vpcflowlogs_cloudwatch.name
  policy_arn = aws_iam_policy.vpcflowlogs_cloudwatch.arn
}
resource "aws_iam_policy" "sns_policy" {
  name    = "sns-policy"
  path    = "/"
  description = "sns policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "snsPublish"
        Effect  = "Allow"
        Action  = [
          "sns:Publish",
          "sns:GetTopicAttributes"
        ]
        Resource = "*"
      }
     ]
   })
}


resource "aws_iam_role" "sns_role" {
  name   = "sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
     { 
       Effect = "Allow"
       Principal = {
         "Service": "sns.amazonaws.com"
       }
       Action = "sts:AssumeRole"
    }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "attach_role" {
  role       = aws_iam_role.sns_role.name
  policy_arn = aws_iam_policy.sns_policy.arn
}

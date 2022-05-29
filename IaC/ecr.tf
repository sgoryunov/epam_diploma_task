resource "aws_ecr_repository" "itunes-gr-repo" {
  name                 = "itunes-gr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
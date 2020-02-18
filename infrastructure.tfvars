# Put your cluster where your data is
region = "us-east-1"

# See https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html for
# more information
map_users = [{
    userarn  = "arn:aws:iam::454929164628:user/yuvipanda"
    username = "yuvipanda"
    groups   = ["system:masters"]
}]

# Name of your cluster
cluster_name = "yuvipanda-test-cluster"

vpc_name = "yuvipanda-test-vpc"
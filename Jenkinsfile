pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
        string(name: 'name', defaultValue: 'vpc', description: 'enter name of your vpc')
        string(name: 'project', defaultValue: 'testing', description: 'enter your project name')
        string(name: 'environment', defaultValue: 'dev', description: 'mention env name')
        string(name: 'region', defaultValue: 'ap-south-1', description: 'mention resource creation region')
        string(name: 'cidr_block', defaultValue: '10.0.0.0/16', description: 'enter the cidr for vpc')
        string(name: 'availability_zone_one', defaultValue: 'ap-south-1a', description: 'enter the az1')
        string(name: 'availability_zone_two', defaultValue: 'ap-south-1b', description: 'enter the az2')
        string(name: 'public_subnet_a_cidr_blocks', defaultValue: '10.0.0.0/24', description: 'enter cidr for public subnet 1a')
        string(name: 'public_subnet_b_cidr_blocks', defaultValue: '10.0.1.0/24', description: 'enter cidr for public subnet 1b')
        string(name: 'private_subnet_a_cidr_blocks', defaultValue: '10.0.2.0/24', description: 'enter cidr for pvt subnet 1a')
        string(name: 'private_subnet_b_cidr_blocks', defaultValue: '10.0.3.0/24', description: 'enter cidr for pvt subnet 1b')
        string(name: 'PARAM_1', defaultValue: '', description: 'Description for PARAM_1')
        string(name: 'instance_sg_name', defaultValue: 'ec2-sg', description: 'sg name')
        string(name: 'ami', defaultValue: 'ami-09298640a92b2d12c', description: 'ami here')
        string(name: 'instance_type', defaultValue: 't2.micro', description: 'instance type')
        string(name: 'key_pair', defaultValue: 'jenkins-test-server2-keypair', description: 'key pair ')
        string(name: 'PARAM_2', defaultValue: '', description: 'Description for PARAM_2')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {
        stage('Vpc Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/juleshkumar/new-test.git'
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Execute Terraform commands for Stage 1
                    sh 'terraform init'
                    sh "terraform plan -out tfplan \
                            -var 'name=${params.name}' \
                            -var 'project=${params.project}' \
                            -var 'environment=${params.environment}' \
                            -var 'region=${params.region}' \
                            -var 'cidr_block=${params.cidr_block}' \
                            -var 'availability_zone_one=${params.availability_zone_one}' \
                            -var 'availability_zone_two=${params.availability_zone_two}' \
                            -var 'public_subnet_a_cidr_blocks=${params.public_subnet_a_cidr_blocks}' \
                            -var 'public_subnet_b_cidr_blocks=${params.public_subnet_b_cidr_blocks}' \
                            -var 'private_subnet_a_cidr_blocks=${params.private_subnet_a_cidr_blocks}' \
                            -var 'private_subnet_b_cidr_blocks=${params.private_subnet_b_cidr_blocks}'"
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                        script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh "terraform ${params.action} -input=false tfplan"
                    } else if (params.action == 'destroy') {
                        sh "terraform ${params.action} --auto-approve \
                                -var 'name=${params.name}' \
                                -var 'project=${params.project}' \
                                -var 'environment=${params.environment}' \
                                -var 'region=${params.region}' \
                                -var 'cidr_block=${params.cidr_block}' \
                                -var 'availability_zone_one=${params.availability_zone_one}' \
                                -var 'availability_zone_two=${params.availability_zone_two}' \
                                -var 'public_subnet_a_cidr_blocks=${params.public_subnet_a_cidr_blocks}' \
                                -var 'public_subnet_b_cidr_blocks=${params.public_subnet_b_cidr_blocks}' \
                                -var 'private_subnet_a_cidr_blocks=${params.private_subnet_a_cidr_blocks}' \
                                -var 'private_subnet_b_cidr_blocks=${params.private_subnet_b_cidr_blocks}'"
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }

            }
                    
                    // Generate outputs.tf file
                    sh 'terraform output -json > outputs.tf'
                }
            }
        }

        stage('Instance Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/juleshkumar/jenkins-ec2.git'
            }
        }

        stage('Terraform Apply Stage 2') {
            steps {
                script {
                    // Read Terraform outputs from file
                    def tfOutputs = readFile 'outputs.tf'
                    def parsedOutputs = readJSON text: tfOutputs

                    // Store output values in environment variables for use in subsequent stages
                    env.PARAM_1 = parsedOutputs.public_subnet_a_ids.value
                    env.PARAM_2 = parsedOutputs.vpc_id.value

                    // Execute Terraform commands for Stage 2
                    sh "terraform plan -out tfplan \
                            -var 'instance_sg_name=${params.instance_sg_name}' \
                            -var 'ami=${params.ami}' \
                            -var 'vpc_id=${env.PARAM_2}' \
                            -var 'instance_type=${params.instance_type}' \
                            -var 'subnet_id=${env.PARAM_1}' \
                            -var 'key_pair=${params.key_pair}'"
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
}

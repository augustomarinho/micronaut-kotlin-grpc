package com.am.app.grpc

import com.am.app.CreateUserRequest
import com.am.app.CreateUserResponse
import com.am.app.UserServiceGrpcKt
import jakarta.inject.Singleton

@Singleton
class DemoGRPCServer : UserServiceGrpcKt.UserServiceCoroutineImplBase() {

    override suspend fun createUser(request: CreateUserRequest): CreateUserResponse {
        return CreateUserResponse
            .newBuilder()
            .setMessage("User Created: ${request.name}")
            .build()
    }
}
package com.am.app.grpc

import com.am.app.CreateUserRequest
import com.am.app.CreateUserResponse
import com.am.app.UserServiceGrpcKt
import com.google.rpc.BadRequest
import com.google.rpc.Code
import io.grpc.Status
import io.grpc.StatusRuntimeException
import io.grpc.protobuf.StatusProto
import jakarta.inject.Singleton

@Singleton
class DemoGRPCServer : UserServiceGrpcKt.UserServiceCoroutineImplBase() {

    override suspend fun createUser(request: CreateUserRequest): CreateUserResponse {
        return when(request.name.lowercase()) {
            "bug" -> throw StatusRuntimeException(Status.INTERNAL);
            "badrequest" -> throw StatusProto.toStatusRuntimeException(BuildErrors.buildBadRequest())
            else ->  CreateUserResponse
                .newBuilder()
                .setMessage("User Created: ${request.name}")
                .build()
        }
    }
}

object BuildErrors {
    fun buildBadRequest(): com.google.rpc.Status {
        return com.google.rpc.Status
            .newBuilder()
            .setCode(Code.INVALID_ARGUMENT_VALUE)
            .setMessage("Requisicao Invalida!")
            .addDetails(com.google.protobuf.Any.pack(BadRequest
                .newBuilder()
                .addFieldViolations(BadRequest.FieldViolation
                    .newBuilder()
                    .setField("nome")
                    .setDescription("Nome Invalido")
                    .build())
                .build()))
            .build()
    }
}
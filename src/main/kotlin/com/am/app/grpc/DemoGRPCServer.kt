package com.am.app.grpc

import com.am.app.DemoReply
import com.am.app.DemoRequest
import com.am.app.DemoServiceGrpcKt.DemoServiceCoroutineImplBase
import jakarta.inject.Singleton

@Singleton
class DemoGRPCServer : DemoServiceCoroutineImplBase() {

    override suspend fun createDemo(request: DemoRequest): DemoReply {
        return DemoReply
            .newBuilder()
            .setMessage("User Created ${request.name}")
            .build()
    }
}
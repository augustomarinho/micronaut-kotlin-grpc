
�x
google/api/http.proto
google.api"y
Http*
rules (2.google.api.HttpRuleRrulesE
fully_decode_reserved_expansion (RfullyDecodeReservedExpansion"�
HttpRule
selector (	Rselector
get (	H Rget
put (	H Rput
post (	H Rpost
delete (	H Rdelete
patch (	H Rpatch7
custom (2.google.api.CustomHttpPatternH Rcustom
body (	Rbody#
response_body (	RresponseBodyE
additional_bindings (2.google.api.HttpRuleRadditionalBindingsB	
pattern";
CustomHttpPattern
kind (	Rkind
path (	RpathBj
com.google.apiB	HttpProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�s
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 X
	
 X

 "
	

 "

 *
	
 *

 '
	
 '

 "
	
$ "
�
  )� Defines the HTTP configuration for an API service. It contains a list of
 [HttpRule][google.api.HttpRule], each specifying the mapping of an RPC method
 to one or more HTTP REST API methods.



 
�
   � A list of HTTP configuration rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


   


   

   

   
�
 (+� When set to true, URL path parameters will be fully URI-decoded except in
 cases of single segment matches in reserved expansion, where "%2F" will be
 left encoded.

 The default behavior is to not decode RFC 6570 reserved characters in multi
 segment matches.


 (

 (&

 ()*
�S
� ��S # gRPC Transcoding

 gRPC Transcoding is a feature for mapping between a gRPC method and one or
 more HTTP REST endpoints. It allows developers to build a single API service
 that supports both gRPC APIs and REST APIs. Many systems, including [Google
 APIs](https://github.com/googleapis/googleapis),
 [Cloud Endpoints](https://cloud.google.com/endpoints), [gRPC
 Gateway](https://github.com/grpc-ecosystem/grpc-gateway),
 and [Envoy](https://github.com/envoyproxy/envoy) proxy support this feature
 and use it for large scale production services.

 `HttpRule` defines the schema of the gRPC/REST mapping. The mapping specifies
 how different portions of the gRPC request message are mapped to the URL
 path, URL query parameters, and HTTP request body. It also controls how the
 gRPC response message is mapped to the HTTP response body. `HttpRule` is
 typically specified as an `google.api.http` annotation on the gRPC method.

 Each mapping specifies a URL path template and an HTTP method. The path
 template may refer to one or more fields in the gRPC request message, as long
 as each field is a non-repeated field with a primitive (non-message) type.
 The path template controls how fields of the request message are mapped to
 the URL path.

 Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get: "/v1/{name=messages/*}"
         };
       }
     }
     message GetMessageRequest {
       string name = 1; // Mapped to URL path.
     }
     message Message {
       string text = 1; // The resource content.
     }

 This enables an HTTP REST to gRPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456`  | `GetMessage(name: "messages/123456")`

 Any fields in the request message which are not bound by the path template
 automatically become HTTP query parameters if there is no HTTP request body.
 For example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get:"/v1/messages/{message_id}"
         };
       }
     }
     message GetMessageRequest {
       message SubMessage {
         string subfield = 1;
       }
       string message_id = 1; // Mapped to URL path.
       int64 revision = 2;    // Mapped to URL query parameter `revision`.
       SubMessage sub = 3;    // Mapped to URL query parameter `sub.subfield`.
     }

 This enables a HTTP JSON to RPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456?revision=2&sub.subfield=foo` |
 `GetMessage(message_id: "123456" revision: 2 sub: SubMessage(subfield:
 "foo"))`

 Note that fields which are mapped to URL query parameters must have a
 primitive type or a repeated primitive type or a non-repeated message type.
 In the case of a repeated type, the parameter can be repeated in the URL
 as `...?param=A&param=B`. In the case of a message type, each field of the
 message is mapped to a separate parameter, such as
 `...?foo.a=A&foo.b=B&foo.c=C`.

 For HTTP methods that allow a request body, the `body` field
 specifies the mapping. Consider a REST update method on the
 message resource collection:

     service Messaging {
       rpc UpdateMessage(UpdateMessageRequest) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "message"
         };
       }
     }
     message UpdateMessageRequest {
       string message_id = 1; // mapped to the URL
       Message message = 2;   // mapped to the body
     }

 The following HTTP JSON to RPC mapping is enabled, where the
 representation of the JSON in the request body is determined by
 protos JSON encoding:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" message { text: "Hi!" })`

 The special name `*` can be used in the body mapping to define that
 every field not bound by the path template should be mapped to the
 request body.  This enables the following alternative definition of
 the update method:

     service Messaging {
       rpc UpdateMessage(Message) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "*"
         };
       }
     }
     message Message {
       string message_id = 1;
       string text = 2;
     }


 The following HTTP JSON to RPC mapping is enabled:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" text: "Hi!")`

 Note that when using `*` in the body mapping, it is not possible to
 have HTTP parameters, as all fields not bound by the path end in
 the body. This makes this option more rarely used in practice when
 defining REST APIs. The common usage of `*` is in custom methods
 which don't use the URL at all for transferring data.

 It is possible to define multiple HTTP methods for one RPC by using
 the `additional_bindings` option. Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
           get: "/v1/messages/{message_id}"
           additional_bindings {
             get: "/v1/users/{user_id}/messages/{message_id}"
           }
         };
       }
     }
     message GetMessageRequest {
       string message_id = 1;
       string user_id = 2;
     }

 This enables the following two alternative HTTP JSON to RPC mappings:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456` | `GetMessage(message_id: "123456")`
 `GET /v1/users/me/messages/123456` | `GetMessage(user_id: "me" message_id:
 "123456")`

 ## Rules for HTTP mapping

 1. Leaf request fields (recursive expansion nested messages in the request
    message) are classified into three categories:
    - Fields referred by the path template. They are passed via the URL path.
    - Fields referred by the [HttpRule.body][google.api.HttpRule.body]. They are passed via the HTTP
      request body.
    - All other fields are passed via the URL query parameters, and the
      parameter name is the field path in the request message. A repeated
      field can be represented as multiple query parameters under the same
      name.
  2. If [HttpRule.body][google.api.HttpRule.body] is "*", there is no URL query parameter, all fields
     are passed via URL path and HTTP request body.
  3. If [HttpRule.body][google.api.HttpRule.body] is omitted, there is no HTTP request body, all
     fields are passed via URL path and URL query parameters.

 ### Path template syntax

     Template = "/" Segments [ Verb ] ;
     Segments = Segment { "/" Segment } ;
     Segment  = "*" | "**" | LITERAL | Variable ;
     Variable = "{" FieldPath [ "=" Segments ] "}" ;
     FieldPath = IDENT { "." IDENT } ;
     Verb     = ":" LITERAL ;

 The syntax `*` matches a single URL path segment. The syntax `**` matches
 zero or more URL path segments, which must be the last part of the URL path
 except the `Verb`.

 The syntax `Variable` matches part of the URL path as specified by its
 template. A variable template must not contain other variables. If a variable
 matches a single path segment, its template may be omitted, e.g. `{var}`
 is equivalent to `{var=*}`.

 The syntax `LITERAL` matches literal text in the URL path. If the `LITERAL`
 contains any reserved character, such characters should be percent-encoded
 before the matching.

 If a variable contains exactly one path segment, such as `"{var}"` or
 `"{var=*}"`, when such a variable is expanded into a URL path on the client
 side, all characters except `[-_.~0-9a-zA-Z]` are percent-encoded. The
 server side does the reverse decoding. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{var}`.

 If a variable contains multiple path segments, such as `"{var=foo/*}"`
 or `"{var=**}"`, when such a variable is expanded into a URL path on the
 client side, all characters except `[-_.~/0-9a-zA-Z]` are percent-encoded.
 The server side does the reverse decoding, except "%2F" and "%2f" are left
 unchanged. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{+var}`.

 ## Using gRPC API Service Configuration

 gRPC API Service Configuration (service config) is a configuration language
 for configuring a gRPC service to become a user-facing product. The
 service config is simply the YAML representation of the `google.api.Service`
 proto message.

 As an alternative to annotating your proto file, you can configure gRPC
 transcoding in your service config YAML files. You do this by specifying a
 `HttpRule` that maps the gRPC method to a REST endpoint, achieving the same
 effect as the proto annotation. This can be particularly useful if you
 have a proto that is reused in multiple services. Note that any transcoding
 specified in the service config will override any matching transcoding
 configuration in the proto.

 Example:

     http:
       rules:
         # Selects a gRPC method and applies HttpRule to it.
         - selector: example.v1.Messaging.GetMessage
           get: /v1/messages/{message_id}/{sub.subfield}

 ## Special notes

 When gRPC Transcoding is used to map a gRPC to JSON REST endpoints, the
 proto to JSON conversion must follow the [proto3
 specification](https://developers.google.com/protocol-buffers/docs/proto3#json).

 While the single segment variable follows the semantics of
 [RFC 6570](https://tools.ietf.org/html/rfc6570) Section 3.2.2 Simple String
 Expansion, the multi segment variable **does not** follow RFC 6570 Section
 3.2.3 Reserved Expansion. The reason is that the Reserved Expansion
 does not expand special characters like `?` and `#`, which would lead
 to invalid URLs. As the result, gRPC Transcoding uses a custom encoding
 for multi segment variables.

 The path variables **must not** refer to any repeated or mapped field,
 because client libraries are not capable of handling such variable expansion.

 The path variables **must not** capture the leading "/" character. The reason
 is that the most common use case "{var}" does not capture the leading "/"
 character. For consistency, all path variables must share the same behavior.

 Repeated message fields must not be mapped to URL query parameters, because
 no client library can support such complicated mapping.

 If an API needs to use a JSON array for request or response body, it can map
 the request or response body to a repeated field. However, some gRPC
 Transcoding implementations may not support this feature.


�
�
 � Selects a method to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 �

 �	

 �
�
 ��� Determines the URL pattern is matched by this rules. This pattern can be
 used with any of the {get|put|post|delete|patch} methods. A custom method
 can be defined using the 'custom' field.


 �
\
�N Maps to HTTP GET. Used for listing and getting information about
 resources.


�


�

�
@
�2 Maps to HTTP PUT. Used for replacing a resource.


�


�

�
X
�J Maps to HTTP POST. Used for creating a resource or performing an action.


�


�

�
B
�4 Maps to HTTP DELETE. Used for deleting a resource.


�


�

�
A
�3 Maps to HTTP PATCH. Used for updating a resource.


�


�

�
�
�!� The custom pattern is used for specifying an HTTP method that is not
 included in the `pattern` field, such as HEAD, or "*" to leave the
 HTTP method unspecified for this rule. The wild-card rule is useful
 for services that provide content to Web (HTML) clients.


�

�

� 
�
�� The name of the request field whose value is mapped to the HTTP request
 body, or `*` for mapping all request fields not captured by the path
 pattern to the HTTP body, or omitted for not having any HTTP request body.

 NOTE: the referred field must be present at the top-level of the request
 message type.


�

�	

�
�
�� Optional. The name of the response field whose value is mapped to the HTTP
 response body. When omitted, the entire response message will be used
 as the HTTP response body.

 NOTE: The referred field must be present at the top-level of the response
 message type.


�

�	

�
�
	�-� Additional HTTP bindings for the selector. Nested bindings must
 not contain an `additional_bindings` field themselves (that is,
 the nesting may only be one level deep).


	�


	�

	�'

	�*,
G
� �9 A custom pattern is used for defining custom HTTP verb.


�
2
 �$ The name of this custom HTTP verb.


 �

 �	

 �
5
�' The path matched by this custom verb.


�

�	

�bproto3
҉
 google/protobuf/descriptor.protogoogle.protobuf"M
FileDescriptorSet8
file (2$.google.protobuf.FileDescriptorProtoRfile"�
FileDescriptorProto
name (	Rname
package (	Rpackage

dependency (	R
dependency+
public_dependency
 (RpublicDependency'
weak_dependency (RweakDependencyC
message_type (2 .google.protobuf.DescriptorProtoRmessageTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeA
service (2'.google.protobuf.ServiceDescriptorProtoRserviceC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extension6
options (2.google.protobuf.FileOptionsRoptionsI
source_code_info	 (2.google.protobuf.SourceCodeInfoRsourceCodeInfo
syntax (	Rsyntax"�
DescriptorProto
name (	Rname;
field (2%.google.protobuf.FieldDescriptorProtoRfieldC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extensionA
nested_type (2 .google.protobuf.DescriptorProtoR
nestedTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeX
extension_range (2/.google.protobuf.DescriptorProto.ExtensionRangeRextensionRangeD

oneof_decl (2%.google.protobuf.OneofDescriptorProtoR	oneofDecl9
options (2.google.protobuf.MessageOptionsRoptionsU
reserved_range	 (2..google.protobuf.DescriptorProto.ReservedRangeRreservedRange#
reserved_name
 (	RreservedNamez
ExtensionRange
start (Rstart
end (Rend@
options (2&.google.protobuf.ExtensionRangeOptionsRoptions7
ReservedRange
start (Rstart
end (Rend"|
ExtensionRangeOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
FieldDescriptorProto
name (	Rname
number (RnumberA
label (2+.google.protobuf.FieldDescriptorProto.LabelRlabel>
type (2*.google.protobuf.FieldDescriptorProto.TypeRtype
	type_name (	RtypeName
extendee (	Rextendee#
default_value (	RdefaultValue
oneof_index	 (R
oneofIndex
	json_name
 (	RjsonName7
options (2.google.protobuf.FieldOptionsRoptions'
proto3_optional (Rproto3Optional"�
Type
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"C
Label
LABEL_OPTIONAL
LABEL_REQUIRED
LABEL_REPEATED"c
OneofDescriptorProto
name (	Rname7
options (2.google.protobuf.OneofOptionsRoptions"�
EnumDescriptorProto
name (	Rname?
value (2).google.protobuf.EnumValueDescriptorProtoRvalue6
options (2.google.protobuf.EnumOptionsRoptions]
reserved_range (26.google.protobuf.EnumDescriptorProto.EnumReservedRangeRreservedRange#
reserved_name (	RreservedName;
EnumReservedRange
start (Rstart
end (Rend"�
EnumValueDescriptorProto
name (	Rname
number (Rnumber;
options (2!.google.protobuf.EnumValueOptionsRoptions"�
ServiceDescriptorProto
name (	Rname>
method (2&.google.protobuf.MethodDescriptorProtoRmethod9
options (2.google.protobuf.ServiceOptionsRoptions"�
MethodDescriptorProto
name (	Rname

input_type (	R	inputType
output_type (	R
outputType8
options (2.google.protobuf.MethodOptionsRoptions0
client_streaming (:falseRclientStreaming0
server_streaming (:falseRserverStreaming"�	
FileOptions!
java_package (	RjavaPackage0
java_outer_classname (	RjavaOuterClassname5
java_multiple_files
 (:falseRjavaMultipleFilesD
java_generate_equals_and_hash (BRjavaGenerateEqualsAndHash:
java_string_check_utf8 (:falseRjavaStringCheckUtf8S
optimize_for	 (2).google.protobuf.FileOptions.OptimizeMode:SPEEDRoptimizeFor

go_package (	R	goPackage5
cc_generic_services (:falseRccGenericServices9
java_generic_services (:falseRjavaGenericServices5
py_generic_services (:falseRpyGenericServices7
php_generic_services* (:falseRphpGenericServices%

deprecated (:falseR
deprecated.
cc_enable_arenas (:trueRccEnableArenas*
objc_class_prefix$ (	RobjcClassPrefix)
csharp_namespace% (	RcsharpNamespace!
swift_prefix' (	RswiftPrefix(
php_class_prefix( (	RphpClassPrefix#
php_namespace) (	RphpNamespace4
php_metadata_namespace, (	RphpMetadataNamespace!
ruby_package- (	RrubyPackageX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption":
OptimizeMode	
SPEED
	CODE_SIZE
LITE_RUNTIME*	�����J&'"�
MessageOptions<
message_set_wire_format (:falseRmessageSetWireFormatL
no_standard_descriptor_accessor (:falseRnoStandardDescriptorAccessor%

deprecated (:falseR
deprecated
	map_entry (RmapEntryX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����JJJJ	J	
"�
FieldOptionsA
ctype (2#.google.protobuf.FieldOptions.CType:STRINGRctype
packed (RpackedG
jstype (2$.google.protobuf.FieldOptions.JSType:	JS_NORMALRjstype
lazy (:falseRlazy.
unverified_lazy (:falseRunverifiedLazy%

deprecated (:falseR
deprecated
weak
 (:falseRweakX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"/
CType

STRING 
CORD
STRING_PIECE"5
JSType
	JS_NORMAL 
	JS_STRING
	JS_NUMBER*	�����J"s
OneofOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
EnumOptions
allow_alias (R
allowAlias%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J"�
EnumValueOptions%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
ServiceOptions%

deprecated! (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
MethodOptions%

deprecated! (:falseR
deprecatedq
idempotency_level" (2/.google.protobuf.MethodOptions.IdempotencyLevel:IDEMPOTENCY_UNKNOWNRidempotencyLevelX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"P
IdempotencyLevel
IDEMPOTENCY_UNKNOWN 
NO_SIDE_EFFECTS

IDEMPOTENT*	�����"�
UninterpretedOptionA
name (2-.google.protobuf.UninterpretedOption.NamePartRname)
identifier_value (	RidentifierValue,
positive_int_value (RpositiveIntValue,
negative_int_value (RnegativeIntValue!
double_value (RdoubleValue!
string_value (RstringValue'
aggregate_value (	RaggregateValueJ
NamePart
	name_part (	RnamePart!
is_extension (RisExtension"�
SourceCodeInfoD
location (2(.google.protobuf.SourceCodeInfo.LocationRlocation�
Location
path (BRpath
span (BRspan)
leading_comments (	RleadingComments+
trailing_comments (	RtrailingComments:
leading_detached_comments (	RleadingDetachedComments"�
GeneratedCodeInfoM

annotation (2-.google.protobuf.GeneratedCodeInfo.AnnotationR
annotationm

Annotation
path (BRpath
source_file (	R
sourceFile
begin (Rbegin
end (RendB~
com.google.protobufBDescriptorProtosHZ-google.golang.org/protobuf/types/descriptorpb��GPB�Google.Protobuf.ReflectionJ��
' �
�
' 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)
  Based on original Protocol Buffers design by
  Sanjay Ghemawat, Jeff Dean, and others.

 The messages in this file describe the definitions found in .proto files.
 A valid .proto file can be translated directly to a FileDescriptorProto
 without any other information (e.g. without reading its imports).


) 

+ D
	
+ D

, ,
	
, ,

- 1
	
- 1

. 7
	
%. 7

/ !
	
$/ !

0 
	
0 

4 

	4 t descriptor.proto must be optimized for speed because reflection-based
 algorithms don't work during bootstrapping.

j
 8 :^ The protocol compiler can output a FileDescriptorSet containing the .proto
 files it parses.



 8

  9(

  9


  9

  9#

  9&'
/
= Z# Describes a complete .proto file.



=
9
 >", file name, relative to root of source tree


 >


 >

 >

 >
*
?" e.g. "foo", "foo.bar", etc.


?


?

?

?
4
B!' Names of files imported by this file.


B


B

B

B 
Q
D(D Indexes of the public imported files in the dependency list above.


D


D

D"

D%'
z
G&m Indexes of the weak imported files in the dependency list.
 For Google-internal migration only. Do not use.


G


G

G 

G#%
6
J,) All top-level definitions in this file.


J


J

J'

J*+

K-

K


K

K(

K+,

L.

L


L!

L")

L,-

M.

M


M

M )

M,-

	O#

	O


	O

	O

	O!"
�

U/� This field contains optional information about the original source code.
 You may safely remove this entire field without harming runtime
 functionality of the descriptors -- the information is needed only by
 development tools.



U



U


U*


U-.
]
YP The syntax of the proto file.
 The supported values are "proto2" and "proto3".


Y


Y

Y

Y
'
] } Describes a message type.



]

 ^

 ^


 ^

 ^

 ^

`*

`


`

` %

`()

a.

a


a

a )

a,-

c+

c


c

c&

c)*

d-

d


d

d(

d+,

 fk

 f


  g" Inclusive.


  g

  g

  g

  g

 h" Exclusive.


 h

 h

 h

 h

 j/

 j

 j"

 j#*

 j-.

l.

l


l

l)

l,-

n/

n


n

n *

n-.

p&

p


p

p!

p$%
�
ux� Range of reserved tag numbers. Reserved tag numbers may not be used by
 fields or extension ranges in the same message. Reserved ranges may
 not overlap.


u


 v" Inclusive.


 v

 v

 v

 v

w" Exclusive.


w

w

w

w

y,

y


y

y'

y*+
�
	|%u Reserved field names, which may not be used by fields in the same message.
 A given name may only be reserved once.


	|


	|

	|

	|"$

 �



O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
3
� �% Describes a field within a message.


�

 ��

 �
S
  �C 0 is reserved for errors.
 Order is weird for historical reasons.


  �

  �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
 negative values are likely.


 �

 �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
 negative values are likely.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
�
 	�� Tag-delimited aggregate.
 Group type is deprecated and not supported in proto3. However, Proto3
 implementations should still be able to parse the group wire format and
 treat group fields as unknown fields.


 	�

 	�
-
 
�" Length-delimited aggregate.


 
�

 
�
#
 � New in version 2.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
'
 �" Uses ZigZag encoding.


 �

 �
'
 �" Uses ZigZag encoding.


 �

 �

��

�
*
 � 0 is reserved for errors


 �

 �

�

�

�

�

�

�

 �

 �


 �

 �

 �

�

�


�

�

�

�

�


�

�

�
�
�� If type_name is set, this need not be set.  If both this and type_name
 are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.


�


�

�

�
�
� � For message and enum types, this is the name of the type.  If the name
 starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
 rules are used to find the type (i.e. first the nested types within this
 message are searched, then within the parent, on up to the root
 namespace).


�


�

�

�
~
�p For extensions, this is the name of the type being extended.  It is
 resolved in the same manner as type_name.


�


�

�

�
�
�$� For numeric types, contains the original text representation of the value.
 For booleans, "true" or "false".
 For strings, contains the default text contents (not escaped in any way).
 For bytes, contains the C escaped value.  All bytes >= 128 are escaped.


�


�

�

�"#
�
�!v If set, gives the index of a oneof in the containing type's oneof_decl
 list.  This field is a member of that oneof.


�


�

�

� 
�
�!� JSON name of this field. The value is set by protocol compiler. If the
 user has set a "json_name" option on this field, that option's value
 will be used. Otherwise, it's deduced from the field's name by converting
 it to camelCase.


�


�

�

� 

	�$

	�


	�

	�

	�"#
�	

�%�	 If true, this is a proto3 "optional". When a proto3 field is optional, it
 tracks presence regardless of field type.

 When proto3_optional is true, this field must be belong to a oneof to
 signal to old proto3 clients that presence is tracked for this field. This
 oneof is known as a "synthetic" oneof, and this field must be its sole
 member (each proto3 optional field gets its own synthetic oneof). Synthetic
 oneofs exist in the descriptor only, and do not generate any API. Synthetic
 oneofs must be ordered after all "real" oneofs.

 For message fields, proto3_optional doesn't create any semantic change,
 since non-repeated message fields always track presence. However it still
 indicates the semantic detail of whether the user wrote "optional" or not.
 This can be useful for round-tripping the .proto file. For consistency we
 give message fields a synthetic oneof also, even though it is not required
 to track presence. This is especially important because the parser can't
 tell if a field is a message or an enum, so it must always create a
 synthetic oneof.

 Proto2 optional fields do not set this flag, because they already indicate
 optional with `LABEL_OPTIONAL`.



�



�


�


�"$
"
� � Describes a oneof.


�

 �

 �


 �

 �

 �

�$

�


�

�

�"#
'
� � Describes an enum type.


�

 �

 �


 �

 �

 �

�.

�


�#

�$)

�,-

�#

�


�

�

�!"
�
 ��� Range of reserved numeric values. Reserved values may not be used by
 entries in the same enum. Reserved ranges may not overlap.

 Note that this is distinct from DescriptorProto.ReservedRange in that it
 is inclusive such that it can appropriately represent the entire int32
 domain.


 �


  �" Inclusive.


  �

  �

  �

  �

 �" Inclusive.


 �

 �

 �

 �
�
�0� Range of reserved numeric values. Reserved numeric values may not be used
 by enum values in the same enum declaration. Reserved ranges may not
 overlap.


�


�

�+

�./
l
�$^ Reserved enum value names, which may not be reused. A given name may only
 be reserved once.


�


�

�

�"#
1
� �# Describes a value within an enum.


� 

 �

 �


 �

 �

 �

�

�


�

�

�

�(

�


�

�#

�&'
$
� � Describes a service.


�

 �

 �


 �

 �

 �

�,

�


� 

�!'

�*+

�&

�


�

�!

�$%
0
	� �" Describes a method of a service.


	�

	 �

	 �


	 �

	 �

	 �
�
	�!� Input and output type names.  These are resolved in the same way as
 FieldDescriptorProto.type_name, but must refer to a message type.


	�


	�

	�

	� 

	�"

	�


	�

	�

	� !

	�%

	�


	�

	� 

	�#$
E
	�77 Identifies if client streams multiple client messages


	�


	�

	� 

	�#$

	�%6

	�05
E
	�77 Identifies if server streams multiple server messages


	�


	�

	� 

	�#$

	�%6

	�05
�

� �2N ===================================================================
 Options
2� Each of the definitions above may have "options" attached.  These are
 just annotations which may cause code to be generated slightly differently
 or may contain hints for code that manipulates protocol messages.

 Clients may define custom options as extensions of the *Options messages.
 These extensions may not yet be known at parsing time, so the parser cannot
 store the values in them.  Instead it stores them in a field in the *Options
 message called uninterpreted_option. This field must have the same name
 across all *Options messages. We then use this field to populate the
 extensions when we build a descriptor, at which point all protos have been
 parsed and so all extensions are known.

 Extension numbers for custom options may be chosen as follows:
 * For options which will only be used within a single application or
   organization, or for experimental options, use field numbers 50000
   through 99999.  It is up to you to ensure that you do not use the
   same number for multiple options.
 * For options which will be published and used publicly by multiple
   independent entities, e-mail protobuf-global-extension-registry@google.com
   to reserve extension numbers. Simply provide your project name (e.g.
   Objective-C plugin) and your project website (if available) -- there's no
   need to explain how you intend to use them. Usually you only need one
   extension number. You can declare multiple options with only one extension
   number by putting them in a sub-message. See the Custom Options section of
   the docs for examples:
   https://developers.google.com/protocol-buffers/docs/proto#options
   If this turns out to be popular, a web service will be set up
   to automatically assign option numbers.



�
�

 �#� Sets the Java package where classes generated from this .proto will be
 placed.  By default, the proto package is used, but this is often
 inappropriate because proto packages do not normally start with backwards
 domain names.



 �



 �


 �


 �!"
�

�+� Controls the name of the wrapper Java class generated for the .proto file.
 That class will always contain the .proto file's getDescriptor() method as
 well as any top-level extensions defined in the .proto file.
 If java_multiple_files is disabled, then all the other classes from the
 .proto file will be nested inside the single wrapper outer class.



�



�


�&


�)*
�

�;� If enabled, then the Java code generator will generate a separate .java
 file for each top-level message, enum, and service defined in the .proto
 file.  Thus, these types will *not* be nested inside the wrapper class
 named by java_outer_classname.  However, the wrapper class will still be
 generated to contain the file's getDescriptor() method as well as any
 top-level extensions defined in the file.



�



�


�#


�&(


�):


�49
)

�E This option does nothing.



�



�


�-


�02


�3D


�4C
�

�>� If set true, then the Java2 code generator will generate code that
 throws an exception whenever an attempt is made to assign a non-UTF-8
 byte sequence to a string field.
 Message reflection will do the same.
 However, an extension field still accepts non-UTF-8 byte sequences.
 This option has no effect on when used with the lite runtime.



�



�


�&


�)+


�,=


�7<
L

 ��< Generated classes can be optimized for speed or code size.



 �
D

  �"4 Generate complete code for parsing, serialization,



  �	


  �
G

 � etc.
"/ Use ReflectionOps to implement these methods.



 �


 �
G

 �"7 Generate code using MessageLite and the lite runtime.



 �


 �


�;


�



�


�$


�'(


�):


�49
�

�"� Sets the Go package where structs generated from this .proto will be
 placed. If omitted, the Go package will be derived from the following:
   - The basename of the package import path, if provided.
   - Otherwise, the package statement in the .proto file, if present.
   - Otherwise, the basename of the .proto file, without extension.



�



�


�


�!
�

�;� Should generic services be generated in each language?  "Generic" services
 are not specific to any particular RPC system.  They are generated by the
 main code generators in each language (without additional plugins).
 Generic services were the only kind of service generation supported by
 early versions of google.protobuf.

 Generic services are now considered deprecated in favor of using plugins
 that generate code specific to your particular RPC system.  Therefore,
 these default to false.  Old code which depends on generic services should
 explicitly set them to true.



�



�


�#


�&(


�):


�49


�=


�



�


�%


�(*


�+<


�6;


	�;


	�



	�


	�#


	�&(


	�):


	�49



�<



�




�



�$



�')



�*;



�5:
�

�2� Is this file deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for everything in the file, or it will be completely ignored; in the very
 least, this is a formalization for deprecating files.



�



�


�


�


� 1


�+0


�7q Enables the use of arenas for the proto messages in this file. This applies
 only to generated classes for C++.



�



�


� 


�#%


�&6


�15
�

�)� Sets the objective c class prefix which is prepended to all objective c
 generated classes from this .proto. There is no default.



�



�


�#


�&(
I

�(; Namespace for generated classes; defaults to the package.



�



�


�"


�%'
�

�$� By default Swift generators will take the proto package and CamelCase it
 replacing '.' with underscore and use that to prefix the types/symbols
 defined. When this options is provided, they will use this value instead
 to prefix the types/symbols defined.



�



�


�


�!#
~

�(p Sets the php class prefix which is prepended to all php generated classes
 from this .proto. Default is empty.



�



�


�"


�%'
�

�%� Use this option to change the namespace of php generated classes. Default
 is empty. When this option is empty, the package name will be used for
 determining the namespace.



�



�


�


�"$
�

�.� Use this option to change the namespace of php generated metadata classes.
 Default is empty. When this option is empty, the proto file name will be
 used for determining the namespace.



�



�


�(


�+-
�

�$� Use this option to change the package of ruby generated classes. Default
 is empty. When this option is not set, the package name will be used for
 determining the ruby package.



�



�


�


�!#
|

�:n The parser stores options it doesn't recognize here.
 See the documentation for the "Options" section above.



�



�


�3


�69
�

�z Clients can define custom options in extensions of this message.
 See the documentation for the "Options" section above.



 �


 �


 �


	�


	 �


	 �


	 �

� �

�
�
 �>� Set true to use the old proto1 MessageSet wire format for extensions.
 This is provided for backwards-compatibility with the MessageSet wire
 format.  You should not use this for any other reason:  It's less
 efficient, has fewer features, and is more complicated.

 The message must be defined exactly as follows:
   message Foo {
     option message_set_wire_format = true;
     extensions 4 to max;
   }
 Note that the message cannot have any defined fields; MessageSets only
 have extensions.

 All extensions of your type must be singular messages; e.g. they cannot
 be int32s, enums, or repeated messages.

 Because this is an option, the above two restrictions are not enforced by
 the protocol compiler.


 �


 �

 �'

 �*+

 �,=

 �7<
�
�F� Disables the generation of the standard "descriptor()" accessor, which can
 conflict with a field of the same name.  This is meant to make migration
 from proto1 easier; new code should avoid fields named "descriptor".


�


�

�/

�23

�4E

�?D
�
�1� Is this message deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the message, or it will be completely ignored; in the very least,
 this is a formalization for deprecating messages.


�


�

�

�

�0

�*/

	�

	 �

	 �

	 �

	�

	�

	�

	�

	�

	�
�
�� Whether the message is an automatically generated map entry type for the
 maps field.

 For maps fields:
     map<KeyType, ValueType> map_field = 1;
 The parsed descriptor looks like:
     message MapFieldEntry {
         option map_entry = true;
         optional KeyType key = 1;
         optional ValueType value = 2;
     }
     repeated MapFieldEntry map_field = 1;

 Implementations may choose not to generate the map_entry=true message, but
 use a native map in the target language to hold the keys and values.
 The reflection APIs in such implementations still need to work as
 if the field is a repeated message field.

 NOTE: Do not set the option in .proto files. Always use the maps syntax
 instead. The option should only be implicitly set by the proto compiler
 parser.


�


�

�

�
$
	�" javalite_serializable


	�

	�

	�

	�" javanano_as_lite


	�

	�

	�
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �.� The ctype option instructs the C++ code generator to use a different
 representation of the field than it normally would.  See the specific
 options below.  This option is not yet implemented in the open source
 release -- sorry, we'll try to include it in a future version!


 �


 �

 �

 �

 �-

 �&,

 ��

 �

  � Default mode.


  �


  �

 �

 �

 �

 �

 �

 �
�
�� The packed option can be enabled for repeated primitive fields to enable
 a more efficient representation on the wire. Rather than repeatedly
 writing the tag and type for each element, the entire array is encoded as
 a single length-delimited blob. In proto3, only explicit setting it to
 false will avoid using packed encoding.


�


�

�

�
�
�3� The jstype option determines the JavaScript type used for values of the
 field.  The option is permitted only for 64 bit integral and fixed types
 (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
 is represented as JavaScript string, which avoids loss of precision that
 can happen when a large value is converted to a floating point JavaScript.
 Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
 use the JavaScript "number" type.  The behavior of the default option
 JS_NORMAL is implementation dependent.

 This option is an enum to permit additional types to be added, e.g.
 goog.math.Integer.


�


�

�

�

�2

�(1

��

�
'
 � Use the default type.


 �

 �
)
� Use JavaScript strings.


�

�
)
� Use JavaScript numbers.


�

�
�
�+� Should this field be parsed lazily?  Lazy applies only to message-type
 fields.  It means that when the outer message is initially parsed, the
 inner message's contents will not be parsed but instead stored in encoded
 form.  The inner message will actually be parsed when it is first accessed.

 This is only a hint.  Implementations are free to choose whether to use
 eager or lazy parsing regardless of the value of this option.  However,
 setting this option true suggests that the protocol author believes that
 using lazy parsing on this field is worth the additional bookkeeping
 overhead typically needed to implement it.

 This option does not affect the public interface of any generated code;
 all method signatures remain the same.  Furthermore, thread-safety of the
 interface is not affected by this option; const methods remain safe to
 call from multiple threads concurrently, while non-const methods continue
 to require exclusive access.


 Note that implementations may choose not to check required fields within
 a lazy sub-message.  That is, calling IsInitialized() on the outer message
 may return true even if the inner message has missing required fields.
 This is necessary because otherwise the inner message would have to be
 parsed in order to perform the check, defeating the purpose of lazy
 parsing.  An implementation which chooses not to check required fields
 must be consistent about it.  That is, for any particular sub-message, the
 implementation must either *always* check its required fields, or *never*
 check its required fields, regardless of whether or not the message has
 been parsed.

 As of 2021, lazy does no correctness checks on the byte stream during
 parsing.  This may lead to crashes if and when an invalid byte stream is
 finally parsed upon access.

 TODO(b/211906113):  Enable validation on lazy fields.


�


�

�

�

�*

�$)
�
�7� unverified_lazy does no correctness checks on the byte stream. This should
 only be used where lazy with verification is prohibitive for performance
 reasons.


�


�

�

�"$

�%6

�05
�
�1� Is this field deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for accessors, or it will be completely ignored; in the very least, this
 is a formalization for deprecating fields.


�


�

�

�

�0

�*/
?
�,1 For Google-internal migration only. Do not use.


�


�

�

�

�+

�%*
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

	�" removed jtype


	 �

	 �

	 �

� �

�
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
`
 � R Set this option to true to allow mapping different tag names to the same
 value.


 �


 �

 �

 �
�
�1� Is this enum deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum, or it will be completely ignored; in the very least, this
 is a formalization for deprecating enums.


�


�

�

�

�0

�*/

	�" javanano_as_lite


	 �

	 �

	 �
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �1� Is this enum value deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum value, or it will be completely ignored; in the very least,
 this is a formalization for deprecating enum values.


 �


 �

 �

 �

 �0

 �*/
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �2� Is this service deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the service, or it will be completely ignored; in the very least,
 this is a formalization for deprecating services.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � 1

 �+0
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �2� Is this method deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the method, or it will be completely ignored; in the very least,
 this is a formalization for deprecating methods.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � 1

 �+0
�
 ��� Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
 or neither? HTTP based RPC implementation may choose GET verb for safe
 methods, and PUT verb for idempotent methods instead of the default POST.


 �

  �

  �

  �
$
 �" implies idempotent


 �

 �
7
 �"' idempotent, but may have side effects


 �

 �

��&

�


�

�-

�02

�%

�$
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
�
� �� A message representing a option the parser does not recognize. This only
 appears in options protos created by the compiler::Parser class.
 DescriptorPool resolves these when building Descriptor objects. Therefore,
 options protos in descriptor objects (e.g. returned by Descriptor::options(),
 or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
 in them.


�
�
 ��� The name of the uninterpreted option.  Each string represents a segment in
 a dot-separated name.  is_extension is true iff a segment represents an
 extension (denoted with parentheses in options specs in .proto files).
 E.g.,{ ["foo", false], ["bar.baz", true], ["moo", false] } represents
 "foo.(bar.baz).moo".


 �


  �"

  �

  �

  �

  � !

 �#

 �

 �

 �

 �!"

 �

 �


 �

 �

 �
�
�'� The value of the uninterpreted option, in whatever type the tokenizer
 identified it as during parsing. Exactly one of these should be set.


�


�

�"

�%&

�)

�


�

�$

�'(

�(

�


�

�#

�&'

�#

�


�

�

�!"

�"

�


�

�

� !

�&

�


�

�!

�$%
�
� �j Encapsulates information about the original source file from which a
 FileDescriptorProto was generated.
2` ===================================================================
 Optional source code info


�
�
 �!� A Location identifies a piece of source code in a .proto file which
 corresponds to a particular definition.  This information is intended
 to be useful to IDEs, code indexers, documentation generators, and similar
 tools.

 For example, say we have a file like:
   message Foo {
     optional string foo = 1;
   }
 Let's look at just the field definition:
   optional string foo = 1;
   ^       ^^     ^^  ^  ^^^
   a       bc     de  f  ghi
 We have the following locations:
   span   path               represents
   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).

 Notes:
 - A location may refer to a repeated field itself (i.e. not to any
   particular index within it).  This is used whenever a set of elements are
   logically enclosed in a single code segment.  For example, an entire
   extend block (possibly containing multiple extension definitions) will
   have an outer location whose path refers to the "extensions" repeated
   field without an index.
 - Multiple locations may have the same path.  This happens when a single
   logical declaration is spread out across multiple places.  The most
   obvious example is the "extend" block again -- there may be multiple
   extend blocks in the same scope, each of which will have the same path.
 - A location's span is not always a subset of its parent's span.  For
   example, the "extendee" of an extension declaration appears at the
   beginning of the "extend" block and is shared by all extensions within
   the block.
 - Just because a location's span is a subset of some other location's span
   does not mean that it is a descendant.  For example, a "group" defines
   both a type and a field in a single declaration.  Thus, the locations
   corresponding to the type and field and their components will overlap.
 - Code which tries to interpret locations should probably be designed to
   ignore those that it doesn't understand, as more types of locations could
   be recorded in the future.


 �


 �

 �

 � 

 ��

 �

�
  �,� Identifies which part of the FileDescriptorProto was defined at this
 location.

 Each element is a field number or an index.  They form a path from
 the root FileDescriptorProto to the place where the definition occurs.
 For example, this path:
   [ 4, 3, 2, 7, 1 ]
 refers to:
   file.message_type(3)  // 4, 3
       .field(7)         // 2, 7
       .name()           // 1
 This is because FileDescriptorProto.message_type has field number 4:
   repeated DescriptorProto message_type = 4;
 and DescriptorProto.field has field number 2:
   repeated FieldDescriptorProto field = 2;
 and FieldDescriptorProto.name has field number 1:
   optional string name = 1;

 Thus, the above path gives the location of a field name.  If we removed
 the last element:
   [ 4, 3, 2, 7 ]
 this path refers to the whole field declaration (from the beginning
 of the label to the terminating semicolon).


  �

  �

  �

  �

  �+

  �*
�
 �,� Always has exactly three or four elements: start line, start column,
 end line (optional, otherwise assumed same as start line), end column.
 These are packed into a single field for efficiency.  Note that line
 and column numbers are zero-based -- typically you will want to add
 1 to each before displaying to a user.


 �

 �

 �

 �

 �+

 �*
�
 �)� If this SourceCodeInfo represents a complete declaration, these are any
 comments appearing before and after the declaration which appear to be
 attached to the declaration.

 A series of line comments appearing on consecutive lines, with no other
 tokens appearing on those lines, will be treated as a single comment.

 leading_detached_comments will keep paragraphs of comments that appear
 before (but not connected to) the current element. Each paragraph,
 separated by empty lines, will be one comment element in the repeated
 field.

 Only the comment content is provided; comment markers (e.g. //) are
 stripped out.  For block comments, leading whitespace and an asterisk
 will be stripped from the beginning of each line other than the first.
 Newlines are included in the output.

 Examples:

   optional int32 foo = 1;  // Comment attached to foo.
   // Comment attached to bar.
   optional int32 bar = 2;

   optional string baz = 3;
   // Comment attached to baz.
   // Another line attached to baz.

   // Comment attached to moo.
   //
   // Another line attached to moo.
   optional double moo = 4;

   // Detached comment for corge. This is not leading or trailing comments
   // to moo or corge because there are blank lines separating it from
   // both.

   // Detached comment for corge paragraph 2.

   optional string corge = 5;
   /* Block comment attached
    * to corge.  Leading asterisks
    * will be removed. */
   /* Block comment attached to
    * grault. */
   optional int32 grault = 6;

   // ignored detached comments.


 �

 �

 �$

 �'(

 �*

 �

 �

 �%

 �()

 �2

 �

 �

 �-

 �01
�
� �� Describes the relationship between generated code and its original source
 file. A GeneratedCodeInfo message is associated with only one generated
 source file, but may contain references to different source .proto files.


�
x
 �%j An Annotation connects some span of text in generated code to an element
 of its generating .proto file.


 �


 �

 � 

 �#$

 ��

 �

�
  �, Identifies the element in the original source .proto file. This field
 is formatted the same as SourceCodeInfo.Location.path.


  �

  �

  �

  �

  �+

  �*
O
 �$? Identifies the filesystem path to the original source .proto.


 �

 �

 �

 �"#
w
 �g Identifies the starting offset in bytes in the generated code
 that relates to the identified object.


 �

 �

 �

 �
�
 �� Identifies the ending offset in bytes in the generated code that
 relates to the identified offset. The end offset should be one past
 the last relevant byte (so the length of the text = end - begin).


 �

 �

 �

 �
�
google/api/annotations.proto
google.apigoogle/api/http.proto google/protobuf/descriptor.proto:K
http.google.protobuf.MethodOptions�ʼ" (2.google.api.HttpRuleRhttpBn
com.google.apiBAnnotationsProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  
	
 *

 X
	
 X

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
	
 

  See `HttpRule`.



 $


 



 


 bproto3
�M
google/api/auth.proto
google.api"~
Authentication4
rules (2.google.api.AuthenticationRuleRrules6
	providers (2.google.api.AuthProviderR	providers"�
AuthenticationRule
selector (	Rselector3
oauth (2.google.api.OAuthRequirementsRoauth8
allow_without_credential (RallowWithoutCredential?
requirements (2.google.api.AuthRequirementRrequirements"h
JwtLocation
header (	H Rheader
query (	H Rquery!
value_prefix (	RvaluePrefixB
in"�
AuthProvider
id (	Rid
issuer (	Rissuer
jwks_uri (	RjwksUri
	audiences (	R	audiences+
authorization_url (	RauthorizationUrl<
jwt_locations (2.google.api.JwtLocationRjwtLocations">
OAuthRequirements)
canonical_scopes (	RcanonicalScopes"P
AuthRequirement
provider_id (	R
providerId
	audiences (	R	audiencesBk
com.google.apiB	AuthProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�E
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 *
	
 *

 '
	
 '

 "
	
$ "
�
 * 2� `Authentication` defines the authentication configuration for API methods
 provided by an API service.

 Example:

     name: calendar.googleapis.com
     authentication:
       providers:
       - id: google_calendar_auth
         jwks_uri: https://www.googleapis.com/oauth2/v1/certs
         issuer: https://securetoken.google.com
       rules:
       - selector: "*"
         requirements:
           provider_id: google_calendar_auth
       - selector: google.calendar.Delegate
         oauth:
           canonical_scopes: https://www.googleapis.com/auth/calendar.read



 *
�
  .(� A list of authentication rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  .


  .

  .#

  .&'
Q
 1&D Defines a set of authentication providers that a service supports.


 1


 1

 1!

 1$%
�
= L� Authentication rules for the service.

 By default, if a method has any authentication requirements, every request
 must include a valid credential matching one of the requirements.
 It's an error to include more than one kind of credential in a single
 request.

 If a method doesn't have any auth requirements, request credentials will be
 ignored.



=
�
 A� Selects the methods to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 A

 A	

 A
6
D) The requirements for OAuth credentials.


D

D

D
�
H$x If true, the service accepts API keys without any other credential.
 This flag only applies to HTTP and gRPC requests.


H

H

H"#
D
K,7 Requirements for additional authentication providers.


K


K

K'

K*+
F
O a: Specifies a location to extract JWT from an API request.



O

 PV

 P

?
 R2 Specifies HTTP header name to extract JWT token.


 R


 R

 R
G
U: Specifies URL query parameter name to extract JWT token.


U


U

U
�
`� The value prefix. The value format is "value_prefix{token}"
 Only applies to "in" header type. Must be empty for "in" query type.
 If not empty, the header value has to match (case sensitive) this prefix.
 If not matched, JWT will not be extracted. If matched, JWT will be
 extracted after the prefix is removed.

 For example, for "Authorization: Bearer {JWT}",
 value_prefix="Bearer " with a space at the end.


`

`	

`
�
f �� Configuration for an authentication provider, including support for
 [JSON Web Token
 (JWT)](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32).



f
�
 k� The unique identifier of the auth provider. It will be referred to by
 `AuthRequirement.provider_id`.

 Example: "bookstore_auth".


 k

 k	

 k
�
s� Identifies the principal that issued the JWT. See
 https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#section-4.1.1
 Usually a URL or an email address.

 Example: https://securetoken.google.com
 Example: 1234567-compute@developer.gserviceaccount.com


s

s	

s
�
�� URL of the provider's public key set to validate signature of the JWT. See
 [OpenID
 Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata).
 Optional if the key set document:
  - can be retrieved from
    [OpenID
    Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)
    of the issuer.
  - can be inferred from the email domain of the issuer (e.g. a Google
  service account).

 Example: https://www.googleapis.com/oauth2/v1/certs


�

�	

�
�
�� The list of JWT
 [audiences](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#section-4.1.3).
 that are allowed to access. A JWT containing any of these audiences will
 be accepted. When this setting is absent, JWTs with audiences:
   - "https://[service.name]/[google.protobuf.Api.name]"
   - "https://[service.name]/"
 will be accepted.
 For example, if no audiences are in the setting, LibraryService API will
 accept JWTs with the following audiences:
   -
   https://library-example.googleapis.com/google.example.library.v1.LibraryService
   - https://library-example.googleapis.com/

 Example:

     audiences: bookstore_android.apps.googleusercontent.com,
                bookstore_web.apps.googleusercontent.com


�

�	

�
�
�� Redirect URL if JWT token is required but not present or is expired.
 Implement authorizationUrl of securityDefinitions in OpenAPI spec.


�

�	

�
�
�)� Defines the locations to extract the JWT.

 JWT locations can be either from HTTP headers or URL query parameters.
 The rule is that the first match wins. The checking order is: checking
 all headers first, then URL query parameters.

 If not specified,  default to use following 3 locations:
    1) Authorization: Bearer
    2) x-goog-iap-jwt-assertion
    3) access_token query parameter

 Default locations can be specified as followings:
    jwt_locations:
    - header: Authorization
      value_prefix: "Bearer "
    - header: x-goog-iap-jwt-assertion
    - query: access_token


�


�

�$

�'(
�
� �� OAuth scopes are a way to define data and permissions on data. For example,
 there are scopes defined for "Read-only access to Google Calendar" and
 "Access to Cloud Platform". Users can consent to a scope for an application,
 giving it permission to access that data on their behalf.

 OAuth scope specifications should be fairly coarse grained; a user will need
 to see and understand the text description of what your scope means.

 In most cases: use one or at most two OAuth scopes for an entire family of
 products. If your product has multiple APIs, you should probably be sharing
 the OAuth scope across all of those APIs.

 When you need finer grained OAuth consent screens: talk with your product
 management about how developers will use them in practice.

 Please note that even though each of the canonical scopes is enough for a
 request to be accepted and passed to the backend, a request can still fail
 due to the backend requiring additional scopes or permissions.


�
�
 �� The list of publicly documented OAuth scopes that are allowed access. An
 OAuth token containing any of these scopes will be accepted.

 Example:

      canonical_scopes: https://www.googleapis.com/auth/calendar,
                        https://www.googleapis.com/auth/calendar.read


 �

 �	

 �
�
� �� User-defined authentication requirements, including support for
 [JSON Web Token
 (JWT)](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32).


�
{
 �m [id][google.api.AuthProvider.id] from authentication provider.

 Example:

     provider_id: bookstore_auth


 �

 �	

 �
�
�� NOTE: This will be deprecated soon, once AuthProvider.audiences is
 implemented and accepted in all the runtime components.

 The list of JWT
 [audiences](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32#section-4.1.3).
 that are allowed to access. A JWT containing any of these audiences will
 be accepted. When this setting is absent, only JWTs with audience
 "https://[Service_name][google.api.Service.name]/[API_name][google.protobuf.Api.name]"
 will be accepted. For example, if no audiences are in the setting,
 LibraryService API will only accept JWTs with the following audience
 "https://library-example.googleapis.com/google.example.library.v1.LibraryService".

 Example:

     audiences: bookstore_android.apps.googleusercontent.com,
                bookstore_web.apps.googleusercontent.com


�

�	

�bproto3
�8
google/api/backend.proto
google.api"8
Backend-
rules (2.google.api.BackendRuleRrules"�
BackendRule
selector (	Rselector
address (	Raddress
deadline (Rdeadline!
min_deadline (RminDeadline-
operation_deadline (RoperationDeadlineR
path_translation (2'.google.api.BackendRule.PathTranslationRpathTranslation#
jwt_audience (	H RjwtAudience#
disable_auth (H RdisableAuth
protocol	 (	Rprotocol"e
PathTranslation 
PATH_TRANSLATION_UNSPECIFIED 
CONSTANT_ADDRESS
APPEND_PATH_TO_ADDRESSB
authenticationBn
com.google.apiBBackendProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�3
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
H
  < `Backend` defines the backend configuration for a service.



 
�
  !� A list of API backend rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  


  

  

   
S
! �F A backend rule provides configuration for an individual API element.



!
�
 )Y� Path Translation specifies how to combine the backend address with the
 request path in order to produce the appropriate forwarding URL for the
 request.

 Path Translation is applicable only to HTTP-based backends. Backends which
 do not accept requests over HTTP/HTTPS should leave `path_translation`
 unspecified.


 )

  *%

  * 

  *#$
�
 C� Use the backend address as-is, with no modification to the path. If the
 URL pattern contains variables, the variable names and values will be
 appended to the query string. If a query string parameter and a URL
 pattern variable have the same name, this may result in duplicate keys in
 the query string.

 # Examples

 Given the following operation config:

     Method path:        /api/company/{cid}/user/{uid}
     Backend address:    https://example.cloudfunctions.net/getUser

 Requests to the following request paths will call the backend at the
 translated path:

     Request path: /api/company/widgetworks/user/johndoe
     Translated:
     https://example.cloudfunctions.net/getUser?cid=widgetworks&uid=johndoe

     Request path: /api/company/widgetworks/user/johndoe?timezone=EST
     Translated:
     https://example.cloudfunctions.net/getUser?timezone=EST&cid=widgetworks&uid=johndoe


 C

 C
�
 X� The request path will be appended to the backend address.

 # Examples

 Given the following operation config:

     Method path:        /api/company/{cid}/user/{uid}
     Backend address:    https://example.appspot.com

 Requests to the following request paths will call the backend at the
 translated path:

     Request path: /api/company/widgetworks/user/johndoe
     Translated:
     https://example.appspot.com/api/company/widgetworks/user/johndoe

     Request path: /api/company/widgetworks/user/johndoe?timezone=EST
     Translated:
     https://example.appspot.com/api/company/widgetworks/user/johndoe?timezone=EST


 X

 X
�
 ^� Selects the methods to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 ^

 ^	

 ^
�
t� The address of the API backend.

 The scheme is used to determine the backend protocol and security.
 The following schemes are accepted:

    SCHEME        PROTOCOL    SECURITY
    http://       HTTP        None
    https://      HTTP        TLS
    grpc://       gRPC        None
    grpcs://      gRPC        TLS

 It is recommended to explicitly include a scheme. Leaving out the scheme
 may cause constrasting behaviors across platforms.

 If the port is unspecified, the default is:
 - 80 for schemes without TLS
 - 443 for schemes with TLS

 For HTTP backends, use [protocol][google.api.BackendRule.protocol]
 to specify the protocol version.


t

t	

t
�
x� The number of seconds to wait for a response from a request. The default
 varies based on the request protocol and deployment environment.


x

x	

x
�
|t Minimum deadline in seconds needed for this method. Calls having deadline
 value lower than this will be rejected.


|

|	

|
z
� l The number of seconds to wait for the completion of a long running
 operation. The default is no deadline.


�

�	

�

�'

�

�"

�%&
�
 ��� Authentication settings used by the backend.

 These are typically used to provide service management functionality to
 a backend served on a publicly-routable URL. The `authentication`
 details should match the authentication behavior used by the backend.

 For example, specifying `jwt_audience` implies that the backend expects
 authentication via a JWT.

 When authentication is unspecified, the resulting behavior is the same
 as `disable_auth` set to `true`.

 Refer to https://developers.google.com/identity/protocols/OpenIDConnect for
 JWT ID token.


 �
�
�� The JWT audience is used when generating a JWT ID token for the backend.
 This ID token will be added in the HTTP "authorization" header, and sent
 to the backend.


�


�

�
�
�� When disable_auth is true, a JWT ID token won't be generated and the
 original "Authorization" HTTP header will be preserved. If the header is
 used to carry the original token and is expected by the backend, this
 field must be set to true to preserve the header.


�

�	

�
�
�� The protocol used for sending a request to the backend.
 The supported values are "http/1.1" and "h2".

 The default value is inferred from the scheme in the
 [address][google.api.BackendRule.address] field:

    SCHEME        PROTOCOL
    http://       http/1.1
    https://      http/1.1
    grpc://       h2
    grpcs://      h2

 For secure HTTP backends (https://) that support HTTP/2, set this field
 to "h2" for improved performance.

 Configuring this field to non-default values is only supported for secure
 HTTP backends. This field will be ignored for all other backends.

 See
 https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml#alpn-protocol-ids
 for more details on the supported values.


�

�	

�bproto3
�
google/api/label.proto
google.api"�
LabelDescriptor
key (	RkeyD

value_type (2%.google.api.LabelDescriptor.ValueTypeR	valueType 
description (	Rdescription",
	ValueType

STRING 
BOOL	
INT64B_
com.google.apiB
LabelProtoPZ5google.golang.org/genproto/googleapis/api/label;label��GAPIJ�

 /
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 L
	
 L

 "
	

 "

 +
	
 +

 '
	
 '

 "
	
$ "
'
  / A description of a label.



 
=
  %/ Value types that can be used as label values.


  
?
   0 A variable-length string. This is the default.


   


   
(
  ! Boolean; true or false.


  !

  !
)
  $ A 64-bit signed integer.


  $	

  $

  ( The label key.


  (

  (	

  (
B
 +5 The type of data that can be assigned to the label.


 +

 +

 +
:
 .- A human-readable description for the label.


 .

 .	

 .bproto3
�
google/api/launch_stage.proto
google.api*�
LaunchStage
LAUNCH_STAGE_UNSPECIFIED 
UNIMPLEMENTED
	PRELAUNCH
EARLY_ACCESS	
ALPHA
BETA
GA

DEPRECATEDBZ
com.google.apiBLaunchStageProtoPZ-google.golang.org/genproto/googleapis/api;api�GAPIJ�
 G
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 D
	
 D

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
�
  Gu The launch stage as defined by [Google Cloud Platform
 Launch Stages](http://cloud.google.com/terms/launch-stages).



 
-
    Do not use this default value.


  

  
H
 ; The feature is not yet implemented. Users can not use it.


 

 
X
 "K Prelaunch features are hidden from users and are only visible internally.


 "

 "
�
 )� Early Access features are limited to a closed group of testers. To use
 these features, you must sign up in advance and sign a Trusted Tester
 agreement (which includes confidentiality provisions). These features may
 be unstable, changed in backward-incompatible ways, and are not
 guaranteed to be released.


 )

 )
�
 4� Alpha is a limited availability test for releases before they are cleared
 for widespread use. By Alpha, all significant design issues are resolved
 and we are in the process of verifying functionality. Alpha customers
 need to apply for access, agree to applicable terms, and have their
 projects allowlisted. Alpha releases don’t have to be feature complete,
 no SLAs are provided, and there are no technical support obligations, but
 they will be far enough along that customers can actually use them in
 test environments or for limited-use tests -- just like they would in
 normal production cases.


 4

 4

�
 ;� Beta is the point at which we are ready to open a release for any
 customer to use. There are no SLA or technical support obligations in a
 Beta release. Products will be complete from a feature perspective, but
 may have some open outstanding issues. Beta releases are suitable for
 limited production use cases.


 ;

 ;	

x
 ?	k GA features are open to all developers and are considered stable and
 fully qualified for production use.


 ?

 ?
�
 F� Deprecated features are scheduled to be shut down and removed. For more
 information, see the “Deprecation Policy” section of our [Terms of
 Service](https://cloud.google.com/terms/)
 and the [Google Cloud Platform Subject to the Deprecation
 Policy](https://cloud.google.com/terms/deprecation) documentation.


 F

 Fbproto3
�%
google/protobuf/duration.protogoogle.protobuf":
Duration
seconds (Rseconds
nanos (RnanosB�
com.google.protobufBDurationProtoPZ1google.golang.org/protobuf/types/known/durationpb��GPB�Google.Protobuf.WellKnownTypesJ�#
 s
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# 
	
# 

$ H
	
$ H

% ,
	
% ,

& .
	
& .

' "
	

' "

( !
	
$( !
�
 f s� A Duration represents a signed, fixed-length span of time represented
 as a count of seconds and fractions of seconds at nanosecond
 resolution. It is independent of any calendar and concepts like "day"
 or "month". It is related to Timestamp in that the difference between
 two Timestamp values is a Duration and it can be added or subtracted
 from a Timestamp. Range is approximately +-10,000 years.

 # Examples

 Example 1: Compute Duration from two Timestamps in pseudo code.

     Timestamp start = ...;
     Timestamp end = ...;
     Duration duration = ...;

     duration.seconds = end.seconds - start.seconds;
     duration.nanos = end.nanos - start.nanos;

     if (duration.seconds < 0 && duration.nanos > 0) {
       duration.seconds += 1;
       duration.nanos -= 1000000000;
     } else if (duration.seconds > 0 && duration.nanos < 0) {
       duration.seconds -= 1;
       duration.nanos += 1000000000;
     }

 Example 2: Compute Timestamp from Timestamp + Duration in pseudo code.

     Timestamp start = ...;
     Duration duration = ...;
     Timestamp end = ...;

     end.seconds = start.seconds + duration.seconds;
     end.nanos = start.nanos + duration.nanos;

     if (end.nanos < 0) {
       end.seconds -= 1;
       end.nanos += 1000000000;
     } else if (end.nanos >= 1000000000) {
       end.seconds += 1;
       end.nanos -= 1000000000;
     }

 Example 3: Compute Duration from datetime.timedelta in Python.

     td = datetime.timedelta(days=3, minutes=10)
     duration = Duration()
     duration.FromTimedelta(td)

 # JSON Mapping

 In JSON format, the Duration type is encoded as a string rather than an
 object, where the string ends in the suffix "s" (indicating seconds) and
 is preceded by the number of seconds, with nanoseconds expressed as
 fractional seconds. For example, 3 seconds with 0 nanoseconds should be
 encoded in JSON format as "3s", while 3 seconds and 1 nanosecond should
 be expressed in JSON format as "3.000000001s", and 3 seconds and 1
 microsecond should be expressed in JSON format as "3.000001s".





 f
�
  j� Signed seconds of the span of time. Must be from -315,576,000,000
 to +315,576,000,000 inclusive. Note: these bounds are computed from:
 60 sec/min * 60 min/hr * 24 hr/day * 365.25 days/year * 10000 years


  j

  j

  j
�
 r� Signed fractions of a second at nanosecond resolution of the span
 of time. Durations less than one second are represented with a 0
 `seconds` field and a positive or negative `nanos` field. For durations
 of one second or more, a non-zero value for the `nanos` field must be
 of the same sign as the `seconds` field. Must be from -999,999,999
 to +999,999,999 inclusive.


 r

 r

 rbproto3
�\
google/api/metric.proto
google.apigoogle/api/label.protogoogle/api/launch_stage.protogoogle/protobuf/duration.proto"�
MetricDescriptor
name (	Rname
type (	Rtype3
labels (2.google.api.LabelDescriptorRlabelsH
metric_kind (2'.google.api.MetricDescriptor.MetricKindR
metricKindE

value_type (2&.google.api.MetricDescriptor.ValueTypeR	valueType
unit (	Runit 
description (	Rdescription!
display_name (	RdisplayNameQ
metadata
 (25.google.api.MetricDescriptor.MetricDescriptorMetadataRmetadata:
launch_stage (2.google.api.LaunchStageRlaunchStage8
monitored_resource_types (	RmonitoredResourceTypes�
MetricDescriptorMetadata>
launch_stage (2.google.api.LaunchStageBRlaunchStage>
sample_period (2.google.protobuf.DurationRsamplePeriod<
ingest_delay (2.google.protobuf.DurationRingestDelay"O

MetricKind
METRIC_KIND_UNSPECIFIED 	
GAUGE	
DELTA

CUMULATIVE"q
	ValueType
VALUE_TYPE_UNSPECIFIED 
BOOL	
INT64

DOUBLE

STRING
DISTRIBUTION	
MONEY"�
Metric
type (	Rtype6
labels (2.google.api.Metric.LabelsEntryRlabels9
LabelsEntry
key (	Rkey
value (	Rvalue:8B_
com.google.apiBMetricProtoPZ7google.golang.org/genproto/googleapis/api/metric;metric�GAPIJ�Q
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
   
	
 '
	
 (

 N
	
 N

 "
	

 "

 ,
	
 ,

 '
	
 '

 "
	
$ "
�
   �� Defines a metric type and its schema. Once a metric descriptor is created,
 deleting or altering it stops data collection and makes the metric type's
 existing data unusable.




  
W
  "0I Additional annotations that can be used to guide the usage of a metric.


  "
"
|
   $5m Deprecated. Must use the [MetricDescriptor.launch_stage][google.api.MetricDescriptor.launch_stage] instead.


   $

   $

   $ 

   $!4

   $"3
�
  */� The sampling period of metric data points. For metrics which are written
 periodically, consecutive data points are stored at this time interval,
 excluding data loss due to errors. Metrics with a higher granularity have
 a smaller sampling period.


  *

  **

  *-.
�
  /.� The delay of data points caused by ingestion. Data points older than this
 age are guaranteed to be ingested and available to be read, excluding
 data loss due to errors.


  /

  /)

  /,-
�
  5E� The kind of measurement. It describes how the data is reported.
 For information on setting the start time and end time based on
 the MetricKind, see [TimeInterval][google.monitoring.v3.TimeInterval].


  5
/
   7   Do not use this default value.


   7

   7
9
  :* An instantaneous measurement of a value.


  :	

  :
>
  =/ The change in a value during a time interval.


  =	

  =
�
  D� A value accumulated over a time interval.  Cumulative
 measurements in a time series should have the same start time
 and increasing end times, until an event resets the cumulative
 value to zero and sets a new start time for the following
 points.


  D

  D
+
 H_ The value type of a metric.


 H
/
  J  Do not use this default value.


  J

  J
i
 NZ The value is a boolean.
 This value type can be used only if the metric kind is `GAUGE`.


 N

 N
6
 Q' The value is a signed 64-bit integer.


 Q	

 Q
G
 T8 The value is a double precision floating point number.


 T


 T
m
 X^ The value is a text string.
 This value type can be used only if the metric kind is `GAUGE`.


 X


 X
J
 [; The value is a [`Distribution`][google.api.Distribution].


 [

 [
$
 ^ The value is money.


 ^	

 ^
:
  b- The resource name of the metric descriptor.


  b

  b	

  b
�
 l� The metric type, including its DNS name prefix. The type is not
 URL-encoded. All user-defined metric types have the DNS name
 `custom.googleapis.com` or `external.googleapis.com`. Metric types should
 use a natural hierarchical grouping. For example:

     "custom.googleapis.com/invoice/paid/amount"
     "external.googleapis.com/prometheus/up"
     "appengine.googleapis.com/http/server/response_latencies"


 l

 l	

 l
�
 t&� The set of labels that can be used to describe a specific
 instance of this metric type. For example, the
 `appengine.googleapis.com/http/server/response_latencies` metric
 type has a label for the HTTP response code, `response_code`, so
 you can look at latencies for successful responses or just
 for responses that failed.


 t


 t

 t!

 t$%
�
 x� Whether the metric records instantaneous values, changes to a value, etc.
 Some combinations of `metric_kind` and `value_type` might not be supported.


 x

 x

 x
�
 |� Whether the measurement is an integer, a floating-point number, etc.
 Some combinations of `metric_kind` and `value_type` might not be supported.


 |

 |

 |
�
 �� The units in which the metric value is reported. It is only applicable
 if the `value_type` is `INT64`, `DOUBLE`, or `DISTRIBUTION`. The `unit`
 defines the representation of the stored metric values.

 Different systems might scale the values to be more easily displayed (so a
 value of `0.02kBy` _might_ be displayed as `20By`, and a value of
 `3523kBy` _might_ be displayed as `3.5MBy`). However, if the `unit` is
 `kBy`, then the value of the metric is always in thousands of bytes, no
 matter how it might be displayed.

 If you want a custom metric to record the exact number of CPU-seconds used
 by a job, you can create an `INT64 CUMULATIVE` metric whose `unit` is
 `s{CPU}` (or equivalently `1s{CPU}` or just `s`). If the job uses 12,005
 CPU-seconds, then the value is written as `12005`.

 Alternatively, if you want a custom metric to record data in a more
 granular way, you can create a `DOUBLE CUMULATIVE` metric whose `unit` is
 `ks{CPU}`, and then write the value `12.005` (which is `12005/1000`),
 or use `Kis{CPU}` and write `11.723` (which is `12005/1024`).

 The supported units are a subset of [The Unified Code for Units of
 Measure](https://unitsofmeasure.org/ucum.html) standard:

 **Basic units (UNIT)**

 * `bit`   bit
 * `By`    byte
 * `s`     second
 * `min`   minute
 * `h`     hour
 * `d`     day
 * `1`     dimensionless

 **Prefixes (PREFIX)**

 * `k`     kilo    (10^3)
 * `M`     mega    (10^6)
 * `G`     giga    (10^9)
 * `T`     tera    (10^12)
 * `P`     peta    (10^15)
 * `E`     exa     (10^18)
 * `Z`     zetta   (10^21)
 * `Y`     yotta   (10^24)

 * `m`     milli   (10^-3)
 * `u`     micro   (10^-6)
 * `n`     nano    (10^-9)
 * `p`     pico    (10^-12)
 * `f`     femto   (10^-15)
 * `a`     atto    (10^-18)
 * `z`     zepto   (10^-21)
 * `y`     yocto   (10^-24)

 * `Ki`    kibi    (2^10)
 * `Mi`    mebi    (2^20)
 * `Gi`    gibi    (2^30)
 * `Ti`    tebi    (2^40)
 * `Pi`    pebi    (2^50)

 **Grammar**

 The grammar also includes these connectors:

 * `/`    division or ratio (as an infix operator). For examples,
          `kBy/{email}` or `MiBy/10ms` (although you should almost never
          have `/s` in a metric `unit`; rates should always be computed at
          query time from the underlying cumulative or delta value).
 * `.`    multiplication or composition (as an infix operator). For
          examples, `GBy.d` or `k{watt}.h`.

 The grammar for a unit is as follows:

     Expression = Component { "." Component } { "/" Component } ;

     Component = ( [ PREFIX ] UNIT | "%" ) [ Annotation ]
               | Annotation
               | "1"
               ;

     Annotation = "{" NAME "}" ;

 Notes:

 * `Annotation` is just a comment if it follows a `UNIT`. If the annotation
    is used alone, then the unit is equivalent to `1`. For examples,
    `{request}/s == 1/s`, `By{transmitted}/s == By/s`.
 * `NAME` is a sequence of non-blank printable ASCII characters not
    containing `{` or `}`.
 * `1` represents a unitary [dimensionless
    unit](https://en.wikipedia.org/wiki/Dimensionless_quantity) of 1, such
    as in `1/s`. It is typically used when none of the basic units are
    appropriate. For example, "new users per day" can be represented as
    `1/d` or `{new-users}/d` (and a metric value `5` would mean "5 new
    users). Alternatively, "thousands of page views per day" would be
    represented as `1000/d` or `k1/d` or `k{page_views}/d` (and a metric
    value of `5.3` would mean "5300 page views per day").
 * `%` represents dimensionless value of 1/100, and annotates values giving
    a percentage (so the metric values are typically in the range of 0..100,
    and a metric value `3` means "3 percent").
 * `10^2.%` indicates a metric contains a ratio, typically in the range
    0..1, that will be multiplied by 100 and displayed as a percentage
    (so a metric value `0.03` means "3 percent").


 �

 �	

 �
Y
 �K A detailed description of the metric, which can be used in documentation.


 �

 �	

 �
�
 �� A concise name for the metric, which can be displayed in user interfaces.
 Use sentence case without an ending period, for example "Request count".
 This field is optional but it is recommended to be set for any metrics
 associated with user-visible concepts, such as Quota.


 �

 �	

 �
R
 �)D Optional. Metadata which can be used to guide usage of the metric.


 �

 �#

 �&(
D
 	� 6 Optional. The launch stage of the metric definition.


 	�

 	�

 	�
�
 
�0� Read-only. If present, then a [time
 series][google.monitoring.v3.TimeSeries], which is identified partially by
 a metric type and a [MonitoredResourceDescriptor][google.api.MonitoredResourceDescriptor], that is associated
 with this metric type can only be associated with one of the monitored
 resource types listed here.


 
�


 
�

 
�*

 
�-/
�
� �� A specific metric, identified by specifying values for all of the
 labels of a [`MetricDescriptor`][google.api.MetricDescriptor].


�
�
 �� An existing metric type, see [google.api.MetricDescriptor][google.api.MetricDescriptor].
 For example, `custom.googleapis.com/invoice/paid/amount`.


 �

 �	

 �
�
�!� The set of label values that uniquely identify this metric. All
 labels listed in the `MetricDescriptor` must be assigned values.


�

�

� bproto3
�
google/api/billing.proto
google.apigoogle/api/metric.proto"�
Billing[
consumer_destinations (2&.google.api.Billing.BillingDestinationRconsumerDestinations]
BillingDestination-
monitored_resource (	RmonitoredResource
metrics (	RmetricsBn
com.google.apiBBillingProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 L
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  !

 \
	
 \

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
�	
 : L�	 Billing related configuration of the service.

 The following example shows how to configure monitored resources and metrics
 for billing, `consumer_destinations` is the only supported destination and
 the monitored resources need at least one label key
 `cloud.googleapis.com/location` to indicate the location of the billing
 usage, using different monitored resources between monitoring and billing is
 recommended so they can be evolved independently:


     monitored_resources:
     - type: library.googleapis.com/billing_branch
       labels:
       - key: cloud.googleapis.com/location
         description: |
           Predefined label to support billing location restriction.
       - key: city
         description: |
           Custom label to define the city where the library branch is located
           in.
       - key: name
         description: Custom label to define the name of the library branch.
     metrics:
     - name: library.googleapis.com/book/borrowed_count
       metric_kind: DELTA
       value_type: INT64
       unit: "1"
     billing:
       consumer_destinations:
       - monitored_resource: library.googleapis.com/billing_branch
         metrics:
         - library.googleapis.com/book/borrowed_count



 :
x
  =Ej Configuration of a specific billing destination (Currently only support
 bill against consumer project).


  =

�
   @"� The monitored resource type. The type must be defined in
 [Service.monitored_resources][google.api.Service.monitored_resources] section.


   @


   @

   @ !
�
  D � Names of the metrics to report to this billing destination.
 Each name must be defined in [Service.metrics][google.api.Service.metrics] section.


  D

  D

  D

  D
�
  K8� Billing configurations for sending metrics to the consumer project.
 There can be multiple consumer destinations per service, each one must have
 a different monitored resource type. A metric can be used in at most
 one consumer destination.


  K


  K

  K3

  K67bproto3
�
google/api/client.proto
google.api google/protobuf/descriptor.proto:J
method_signature.google.protobuf.MethodOptions� (	RmethodSignature:C
default_host.google.protobuf.ServiceOptions� (	RdefaultHost:C
oauth_scopes.google.protobuf.ServiceOptions� (	RoauthScopesBi
com.google.apiBClientProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 b
�
 2� Copyright 2018 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 X
	
 X

 "
	

 "

 ,
	
 ,

 '
	
 '

 "
	
$ "
	
 ?
�
 >*�
 A definition of a client library method signature.

 In client libraries, each proto RPC corresponds to one or more methods
 which the end user is able to call, and calls the underlying RPC.
 Normally, this method receives a single argument (a struct or instance
 corresponding to the RPC request object). Defining this field will
 add one or more overloads providing flattened or simpler method signatures
 in some languages.

 The fields on the method signature are provided as a comma-separated
 string.

 For example, the proto RPC and annotation:

   rpc CreateSubscription(CreateSubscriptionRequest)
       returns (Subscription) {
     option (google.api.method_signature) = "name,topic";
   }

 Would add the following Java overload (in addition to the method accepting
 the request object):

   public final Subscription createSubscription(String name, String topic)

 The following backwards-compatibility guidelines apply:

   * Adding this annotation to an unannotated method is backwards
     compatible.
   * Adding this annotation to a method which already has existing
     method signature annotations is backwards compatible if and only if
     the new method signature annotation is last in the sequence.
   * Modifying or removing an existing method signature annotation is
     a breaking change.
   * Re-ordering existing method signature annotations is a breaking
     change.



 $


 >



 >


 >"


 >%)
	
A b
�
K� The hostname for this service.
 This should be specified with no prefix or protocol.

 Example:

   service Foo {
     option (google.api.default_host) = "foo.googleapi.com";
     ...
   }



A%


K


K	


K
�
a� OAuth scopes needed for the client.

 Example:

   service Foo {
     option (google.api.oauth_scopes) = \
       "https://www.googleapis.com/auth/cloud-platform";
     ...
   }

 If there is more than one scope, use a comma-separated string:

 Example:

   service Foo {
     option (google.api.oauth_scopes) = \
       "https://www.googleapis.com/auth/cloud-platform,"
       "https://www.googleapis.com/auth/monitoring";
     ...
   }



A%


a


a	


abproto3
�
google/api/config_change.proto
google.api"�
ConfigChange
element (	Relement
	old_value (	RoldValue
	new_value (	RnewValue7
change_type (2.google.api.ChangeTypeR
changeType,
advices (2.google.api.AdviceRadvices"*
Advice 
description (	Rdescription*O

ChangeType
CHANGE_TYPE_UNSPECIFIED 	
ADDED
REMOVED
MODIFIEDBq
com.google.apiBConfigChangeProtoPZCgoogle.golang.org/genproto/googleapis/api/configchange;configchange�GAPIJ�
 S
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 Z
	
 Z

 "
	

 "

 2
	
 2

 '
	
 '

 "
	
$ "
�
  8� Output generated from semantically comparing two versions of a service
 configuration.

 Includes detailed information about a field that have changed with
 applicable advice about potential consequences for the change, such as
 backwards-incompatibility.



 
�
  (� Object hierarchy path to the change, with levels separated by a '.'
 character. For repeated fields, an applicable unique identifier field is
 used for the index (usually selector, name, or id). For maps, the term
 'key' is used. If the field has no unique identifier, the numeric index
 is used.
 Examples:
 - visibility.rules[selector=="google.LibraryService.ListBooks"].restriction
 - quota.metric_rules[selector=="google"].metric_costs[key=="reads"].value
 - logging.producer_destinations[0]


  (

  (	

  (
�
 ,� Value of the changed object in the old Service configuration,
 in JSON format. This field will not be populated if ChangeType == ADDED.


 ,

 ,	

 ,
�
 0� Value of the changed object in the new Service configuration,
 in JSON format. This field will not be populated if ChangeType == REMOVED.


 0

 0	

 0
L
 3? The type for this change, either ADDED, REMOVED, or MODIFIED.


 3

 3

 3
y
 7l Collection of advice provided for this change, useful for determining the
 possible impact of this change.


 7


 7

 7

 7
�
< @ Generated advice about this change, used for providing more
 information about how a change will affect the existing service.



<
�
 ?u Useful description for why this advice was applied and what actions should
 be taken to mitigate any implied risks.


 ?

 ?	

 ?
b
 D SV Classifies set of possible modifications to an object in the service
 configuration.



 D
%
  F No value was provided.


  F

  F
y
 Jl The changed object exists in the 'new' service configuration, but not
 in the 'old' service configuration.


 J

 J

y
 Nl The changed object exists in the 'old' service configuration, but not
 in the 'new' service configuration.


 N	

 N
e
 RX The changed object exists in both service configurations, but its value
 is different.


 R


 Rbproto3
�
google/api/consumer.proto
google.api"I
ProjectProperties4

properties (2.google.api.PropertyR
properties"�
Property
name (	Rname5
type (2!.google.api.Property.PropertyTypeRtype 
description (	Rdescription"L
PropertyType
UNSPECIFIED 	
INT64
BOOL

STRING

DOUBLEBh
com.google.apiBConsumerProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfigJ�
 Q
�
 2� Copyright 2016 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 .
	
 .

 '
	
 '
�
 ' *� A descriptor for defining project properties for a service. One service may
 have many consumer projects, and the service may want to behave differently
 depending on some properties on the project. For example, a project may be
 associated with a school, or a business, or a government agency, a business
 type property on the project may affect how a service responds to the client.
 This descriptor defines which properties are allowed to be set on a project.

 Example:

    project_properties:
      properties:
      - name: NO_WATERMARK
        type: BOOL
        description: Allows usage of the API without watermarks.
      - name: EXTENDED_TILE_CACHE_PERIOD
        type: INT64



 '
@
  )#3 List of per consumer project-specific properties.


  )


  )

  )

  )!"
�
6 Q� Defines project properties.

 API services can define properties that can be assigned to consumer projects
 so that backends can perform response customization without having to make
 additional calls or maintain additional storage. For example, Maps API
 defines properties that controls map tile cache period, or whether to embed a
 watermark in a result.

 These values can be set via API producer console. Only API providers can
 define and set these properties.



6
:
 8G, Supported data type of the property values


 8
F
  :7 The type is unspecified, and will result in an error.


  :

  :
%
 = The type is `int64`.


 =	

 =
$
 @ The type is `bool`.


 @

 @
&
 C The type is `string`.


 C


 C
&
 F The type is 'double'.


 F


 F
4
 J' The name of the property (a.k.a key).


 J

 J	

 J
)
M The type of this property.


M

M

M
.
P! The description of the property


P

P	

Pbproto3
�
google/api/context.proto
google.api"8
Context-
rules (2.google.api.ContextRuleRrules"�
ContextRule
selector (	Rselector
	requested (	R	requested
provided (	Rprovided<
allowed_request_extensions (	RallowedRequestExtensions>
allowed_response_extensions (	RallowedResponseExtensionsBn
com.google.apiBContextProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 X
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
�
 < A� `Context` defines which contexts an API requests.

 Example:

     context:
       rules:
       - selector: "*"
         requested:
         - google.rpc.context.ProjectContext
         - google.rpc.context.OriginContext

 The above specifies that all methods in the API request
 `google.rpc.context.ProjectContext` and
 `google.rpc.context.OriginContext`.

 Available context types are defined in package
 `google.rpc.context`.

 This also provides mechanism to allowlist any protobuf message extension that
 can be sent in grpc metadata using “x-goog-ext-<extension_id>-bin” and
 “x-goog-ext-<extension_id>-jspb” format. For example, list any service
 specific protobuf types that can appear in grpc metadata as follows in your
 yaml file:

 Example:

     context:
       rules:
        - selector: "google.example.library.v1.LibraryService.CreateBook"
          allowed_request_extensions:
          - google.foo.v1.NewExtension
          allowed_response_extensions:
          - google.foo.v1.NewExtension

 You can also specify extension ID instead of fully qualified extension name
 here.



 <
�
  @!� A list of RPC context rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  @


  @

  @

  @ 
c
E XW A context rule provides information about the context for an individual API
 element.



E
�
 I� Selects the methods to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 I

 I	

 I
?
L 2 A list of full type names of requested contexts.


L


L

L

L
>
O1 A list of full type names of provided contexts.


O


O

O

O
}
S1p A list of full type names or extension IDs of extensions allowed in grpc
 side channel from client to backend.


S


S

S,

S/0
}
W2p A list of full type names or extension IDs of extensions allowed in grpc
 side channel from backend to client.


W


W

W-

W01bproto3
�	
google/api/control.proto
google.api"+
Control 
environment (	RenvironmentBn
com.google.apiBControlProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
�
  � Selects and configures the service controller used by the service.  The
 service controller handles features like abuse, quota, billing, logging,
 monitoring, etc.



 
�
  w The service control environment to use. If empty, no control plane
 feature (like quota and billing) will be enabled.


  

  	

  bproto3
�,
google/protobuf/any.protogoogle.protobuf"6
Any
type_url (	RtypeUrl
value (RvalueBv
com.google.protobufBAnyProtoPZ,google.golang.org/protobuf/types/known/anypb�GPB�Google.Protobuf.WellKnownTypesJ�*
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# C
	
# C

$ ,
	
$ ,

% )
	
% )

& "
	

& "

' !
	
$' !
�
 | �� `Any` contains an arbitrary serialized protocol buffer message along with a
 URL that describes the type of the serialized message.

 Protobuf library provides support to pack/unpack Any values in the form
 of utility functions or additional generated methods of the Any type.

 Example 1: Pack and unpack a message in C++.

     Foo foo = ...;
     Any any;
     any.PackFrom(foo);
     ...
     if (any.UnpackTo(&foo)) {
       ...
     }

 Example 2: Pack and unpack a message in Java.

     Foo foo = ...;
     Any any = Any.pack(foo);
     ...
     if (any.is(Foo.class)) {
       foo = any.unpack(Foo.class);
     }

 Example 3: Pack and unpack a message in Python.

     foo = Foo(...)
     any = Any()
     any.Pack(foo)
     ...
     if any.Is(Foo.DESCRIPTOR):
       any.Unpack(foo)
       ...

 Example 4: Pack and unpack a message in Go

      foo := &pb.Foo{...}
      any, err := anypb.New(foo)
      if err != nil {
        ...
      }
      ...
      foo := &pb.Foo{}
      if err := any.UnmarshalTo(foo); err != nil {
        ...
      }

 The pack methods provided by protobuf library will by default use
 'type.googleapis.com/full.type.name' as the type URL and the unpack
 methods only use the fully qualified type name after the last '/'
 in the type URL, for example "foo.bar.com/x/y.z" will yield type
 name "y.z".


 JSON

 The JSON representation of an `Any` value uses the regular
 representation of the deserialized, embedded message, with an
 additional field `@type` which contains the type URL. Example:

     package google.profile;
     message Person {
       string first_name = 1;
       string last_name = 2;
     }

     {
       "@type": "type.googleapis.com/google.profile.Person",
       "firstName": <string>,
       "lastName": <string>
     }

 If the embedded message type is well-known and has a custom JSON
 representation, that representation will be embedded adding a field
 `value` which holds the custom JSON in addition to the `@type`
 field. Example (for message [google.protobuf.Duration][]):

     {
       "@type": "type.googleapis.com/google.protobuf.Duration",
       "value": "1.212s"
     }




 |
�

  ��
 A URL/resource name that uniquely identifies the type of the serialized
 protocol buffer message. This string must contain at least
 one "/" character. The last segment of the URL's path must represent
 the fully qualified name of the type (as in
 `path/google.protobuf.Duration`). The name should be in a canonical form
 (e.g., leading "." is not accepted).

 In practice, teams usually precompile into the binary all types that they
 expect it to use in the context of Any. However, for URLs which use the
 scheme `http`, `https`, or no scheme, one can optionally set up a type
 server that maps type URLs to message definitions as follows:

 * If no scheme is provided, `https` is assumed.
 * An HTTP GET on the URL must yield a [google.protobuf.Type][]
   value in binary format, or produce an error.
 * Applications are allowed to cache lookup results based on the
   URL, or have them precompiled into a binary to avoid any
   lookup. Therefore, binary compatibility needs to be preserved
   on changes to types. (Use versioned type names to manage
   breaking changes.)

 Note: this functionality is not currently available in the official
 protobuf release, and it is not used for type URLs beginning with
 type.googleapis.com.

 Schemes other than `http`, `https` (or the empty scheme) might be
 used with implementation specific semantics.



  �

  �	

  �
W
 �I Must be a valid serialized protocol buffer of the above specified type.


 �

 �

 �bproto3
�1
google/protobuf/timestamp.protogoogle.protobuf";
	Timestamp
seconds (Rseconds
nanos (RnanosB�
com.google.protobufBTimestampProtoPZ2google.golang.org/protobuf/types/known/timestamppb��GPB�Google.Protobuf.WellKnownTypesJ�/
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# 
	
# 

$ I
	
$ I

% ,
	
% ,

& /
	
& /

' "
	

' "

( !
	
$( !
�
 � �� A Timestamp represents a point in time independent of any time zone or local
 calendar, encoded as a count of seconds and fractions of seconds at
 nanosecond resolution. The count is relative to an epoch at UTC midnight on
 January 1, 1970, in the proleptic Gregorian calendar which extends the
 Gregorian calendar backwards to year one.

 All minutes are 60 seconds long. Leap seconds are "smeared" so that no leap
 second table is needed for interpretation, using a [24-hour linear
 smear](https://developers.google.com/time/smear).

 The range is from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59.999999999Z. By
 restricting to that range, we ensure that we can convert to and from [RFC
 3339](https://www.ietf.org/rfc/rfc3339.txt) date strings.

 # Examples

 Example 1: Compute Timestamp from POSIX `time()`.

     Timestamp timestamp;
     timestamp.set_seconds(time(NULL));
     timestamp.set_nanos(0);

 Example 2: Compute Timestamp from POSIX `gettimeofday()`.

     struct timeval tv;
     gettimeofday(&tv, NULL);

     Timestamp timestamp;
     timestamp.set_seconds(tv.tv_sec);
     timestamp.set_nanos(tv.tv_usec * 1000);

 Example 3: Compute Timestamp from Win32 `GetSystemTimeAsFileTime()`.

     FILETIME ft;
     GetSystemTimeAsFileTime(&ft);
     UINT64 ticks = (((UINT64)ft.dwHighDateTime) << 32) | ft.dwLowDateTime;

     // A Windows tick is 100 nanoseconds. Windows epoch 1601-01-01T00:00:00Z
     // is 11644473600 seconds before Unix epoch 1970-01-01T00:00:00Z.
     Timestamp timestamp;
     timestamp.set_seconds((INT64) ((ticks / 10000000) - 11644473600LL));
     timestamp.set_nanos((INT32) ((ticks % 10000000) * 100));

 Example 4: Compute Timestamp from Java `System.currentTimeMillis()`.

     long millis = System.currentTimeMillis();

     Timestamp timestamp = Timestamp.newBuilder().setSeconds(millis / 1000)
         .setNanos((int) ((millis % 1000) * 1000000)).build();


 Example 5: Compute Timestamp from Java `Instant.now()`.

     Instant now = Instant.now();

     Timestamp timestamp =
         Timestamp.newBuilder().setSeconds(now.getEpochSecond())
             .setNanos(now.getNano()).build();


 Example 6: Compute Timestamp from current time in Python.

     timestamp = Timestamp()
     timestamp.GetCurrentTime()

 # JSON Mapping

 In JSON format, the Timestamp type is encoded as a string in the
 [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format. That is, the
 format is "{year}-{month}-{day}T{hour}:{min}:{sec}[.{frac_sec}]Z"
 where {year} is always expressed using four digits while {month}, {day},
 {hour}, {min}, and {sec} are zero-padded to two digits each. The fractional
 seconds, which can go up to 9 digits (i.e. up to 1 nanosecond resolution),
 are optional. The "Z" suffix indicates the timezone ("UTC"); the timezone
 is required. A proto3 JSON serializer should always use UTC (as indicated by
 "Z") when printing the Timestamp type and a proto3 JSON parser should be
 able to accept both UTC and other timezones (as indicated by an offset).

 For example, "2017-01-15T01:30:15.01Z" encodes 15.01 seconds past
 01:30 UTC on January 15, 2017.

 In JavaScript, one can convert a Date object to this format using the
 standard
 [toISOString()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString)
 method. In Python, a standard `datetime.datetime` object can be converted
 to this format using
 [`strftime`](https://docs.python.org/2/library/time.html#time.strftime) with
 the time format spec '%Y-%m-%dT%H:%M:%S.%fZ'. Likewise, in Java, one can use
 the Joda Time's [`ISODateTimeFormat.dateTime()`](
 http://www.joda.org/joda-time/apidocs/org/joda/time/format/ISODateTimeFormat.html#dateTime%2D%2D
 ) to obtain a formatter capable of generating timestamps in this format.




 �
�
  �� Represents seconds of UTC time since Unix epoch
 1970-01-01T00:00:00Z. Must be from 0001-01-01T00:00:00Z to
 9999-12-31T23:59:59Z inclusive.


  �

  �

  �
�
 �� Non-negative fractions of a second at nanosecond resolution. Negative
 second values with fractions must still have non-negative nanos values
 that count forward in time. Must be from 0 to 999,999,999
 inclusive.


 �

 �

 �bproto3
�N
google/api/distribution.proto
google.apigoogle/protobuf/any.protogoogle/protobuf/timestamp.proto"�
Distribution
count (Rcount
mean (Rmean7
sum_of_squared_deviation (RsumOfSquaredDeviation4
range (2.google.api.Distribution.RangeRrangeM
bucket_options (2&.google.api.Distribution.BucketOptionsRbucketOptions#
bucket_counts (RbucketCounts?
	exemplars
 (2!.google.api.Distribution.ExemplarR	exemplars+
Range
min (Rmin
max (Rmax�
BucketOptionsV
linear_buckets (2-.google.api.Distribution.BucketOptions.LinearH RlinearBucketse
exponential_buckets (22.google.api.Distribution.BucketOptions.ExponentialH RexponentialBuckets\
explicit_buckets (2/.google.api.Distribution.BucketOptions.ExplicitH RexplicitBucketsd
Linear,
num_finite_buckets (RnumFiniteBuckets
width (Rwidth
offset (Roffsetv
Exponential,
num_finite_buckets (RnumFiniteBuckets#
growth_factor (RgrowthFactor
scale (Rscale"
Explicit
bounds (RboundsB	
options�
Exemplar
value (Rvalue8
	timestamp (2.google.protobuf.TimestampR	timestamp6
attachments (2.google.protobuf.AnyRattachmentsBq
com.google.apiBDistributionProtoPZCgoogle.golang.org/genproto/googleapis/api/distribution;distribution�GAPIJ�C
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #
	
 )

 Z
	
 Z

 "
	

 "

 2
	
 2

 '
	
 '

 "
	
$ "
�
 ) �� `Distribution` contains summary statistics for a population of values. It
 optionally contains a histogram representing the distribution of those values
 across a set of buckets.

 The summary statistics are the count, mean, sum of the squared deviation from
 the mean, the minimum, and the maximum of the set of population of values.
 The histogram is based on a sequence of buckets and gives a count of values
 that fall into each bucket. The boundaries of the buckets are given either
 explicitly or by formulas for buckets of fixed or exponentially increasing
 widths.

 Although it is not forbidden, it is generally a bad idea to include
 non-finite values (infinities or NaNs) in the population of values, as this
 will render the `mean` and `sum_of_squared_deviation` fields meaningless.



 )
3
  +1% The range of the population values.


  +

6
   -' The minimum of the population values.


   -


   -

   -
6
  0' The maximum of the population values.


  0


  0

  0
�
 B�� `BucketOptions` describes the bucket boundaries used to create a histogram
 for the distribution. The buckets can be in a linear sequence, an
 exponential sequence, or each bucket can be specified explicitly.
 `BucketOptions` does not include the number of values in each bucket.

 A bucket has an inclusive lower bound and exclusive upper bound for the
 values that are counted for that bucket. The upper bound of a bucket must
 be strictly greater than the lower bound. The sequence of N buckets for a
 distribution consists of an underflow bucket (number 0), zero or more
 finite buckets (number 1 through N - 2) and an overflow bucket (number N -
 1). The buckets are contiguous: the lower bound of bucket i (i > 0) is the
 same as the upper bound of bucket i - 1. The buckets span the whole range
 of finite values: lower bound of the underflow bucket is -infinity and the
 upper bound of the overflow bucket is +infinity. The finite buckets are
 so-called because both bounds are finite.


 B

�
  LU� Specifies a linear sequence of buckets that all have the same width
 (except overflow and underflow). Each bucket represents a constant
 absolute uncertainty on the specific value in the bucket.

 There are `num_finite_buckets + 2` (= N) buckets. Bucket `i` has the
 following boundaries:

    Upper bound (0 <= i < N-1):     offset + (width * i).
    Lower bound (1 <= i < N):       offset + (width * (i - 1)).


  L
*
   N# Must be greater than 0.


	   N

	   N

	   N!"
*
  Q Must be greater than 0.


	  Q

	  Q

	  Q
3
  T" Lower bound of the first bucket.


	  T

	  T

	  T
�
 `i� Specifies an exponential sequence of buckets that have a width that is
 proportional to the value of the lower bound. Each bucket represents a
 constant relative uncertainty on a specific value in the bucket.

 There are `num_finite_buckets + 2` (= N) buckets. Bucket `i` has the
 following boundaries:

    Upper bound (0 <= i < N-1):     scale * (growth_factor ^ i).
    Lower bound (1 <= i < N):       scale * (growth_factor ^ (i - 1)).


 `
*
  b# Must be greater than 0.


	  b

	  b

	  b!"
*
 e Must be greater than 1.


	 e

	 e

	 e
*
 h Must be greater than 0.


	 h

	 h

	 h
�
 vy� Specifies a set of buckets with arbitrary widths.

 There are `size(bounds) + 1` (= N) buckets. Bucket `i` has the following
 boundaries:

    Upper bound (0 <= i < N-1):     bounds[i]
    Lower bound (1 <= i < N);       bounds[i - 1]

 The `bounds` field must contain at least one element. If `bounds` has
 only one element, then there are no finite buckets, and that single
 element is the common boundary of the overflow and underflow buckets.


 v
?
  x!. The values must be monotonically increasing.


	  x

	  x

	  x

	  x 
A
  |�0 Exactly one of these three fields must be set.


  |

#
  ~  The linear bucket.


  ~

  ~

  ~
*
 �* The exponential buckets.


 �

 �%

 �()
'
 �$ The explicit buckets.


 �

 �

 �"#
�
 ��� Exemplars are example points that may be used to annotate aggregated
 distribution values. They are metadata that gives information about a
 particular value added to a Distribution bucket, such as a trace ID that
 was active when a value was added. They may contain further information,
 such as a example values and timestamps, origin, etc.


 �

k
  �[ Value of the exemplar point. This value determines to which bucket the
 exemplar belongs.


  �


  �

  �
E
 �,5 The observation (sampling) time of the above value.


 �

 �'

 �*+
�
 �1� Contextual information about the example value. Examples are:

   Trace: type.googleapis.com/google.monitoring.v3.SpanContext

   Literal string: type.googleapis.com/google.protobuf.StringValue

   Labels dropped during aggregation:
     type.googleapis.com/google.monitoring.v3.DroppedLabels

 There may be only a single attachment of any given message type in a
 single exemplar, and this is enforced by the system.


 �

 � 

 �!,

 �/0
�
  �� The number of values in the population. Must be non-negative. This value
 must equal the sum of the values in `bucket_counts` if a histogram is
 provided.


  �

  �

  �
v
 �h The arithmetic mean of the values in the population. If `count` is zero
 then this field must be zero.


 �

 �	

 �
�
 �&� The sum of squared deviations from the mean of the values in the
 population. For values x_i this is:

     Sum[i=1..n]((x_i - mean)^2)

 Knuth, "The Art of Computer Programming", Vol. 2, page 232, 3rd edition
 describes Welford's method for accumulating this sum in one pass.

 If `count` is zero then this field must be zero.


 �

 �	!

 �$%
�
 �s If specified, contains the range of the population values. The field
 must not be present if the `count` is zero.


 �

 �

 �
�
 �#s Defines the histogram bucket boundaries. If the distribution does not
 contain a histogram, then omit this field.


 �

 �

 �!"
�
 �#� The number of values in each bucket of the histogram, as described in
 `bucket_options`. If the distribution does not have a histogram, then omit
 this field. If there is a histogram, then the sum of the values in
 `bucket_counts` must equal the value in the `count` field of the
 distribution.

 If present, `bucket_counts` should contain N values, where N is the number
 of buckets specified in `bucket_options`. If you supply fewer than N
 values, the remaining values are assumed to be 0.

 The order of the values in `bucket_counts` follows the bucket numbering
 schemes described for the three bucket types. The first value must be the
 count for the underflow bucket (number 0). The next N-2 values are the
 counts for the finite buckets (number 1 through N-2). The N'th value in
 `bucket_counts` is the count for the overflow bucket (number N-1).


 �


 �

 �

 �!"
=
 �#/ Must be in increasing order of `value` field.


 �


 �

 �

 � "bproto3
�7
google/api/documentation.proto
google.api"�
Documentation
summary (	Rsummary&
pages (2.google.api.PageRpages3
rules (2.google.api.DocumentationRuleRrules4
documentation_root_url (	RdocumentationRootUrl(
service_root_url (	RserviceRootUrl
overview (	Roverview"�
DocumentationRule
selector (	Rselector 
description (	Rdescription7
deprecation_description (	RdeprecationDescription"b
Page
name (	Rname
content (	Rcontent,
subpages (2.google.api.PageRsubpagesBt
com.google.apiBDocumentationProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�1
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 3
	
 3

 '
	
 '

 "
	
$ "
�
 O s� `Documentation` provides the information for describing a service.

 Example:
 <pre><code>documentation:
   summary: >
     The Google Calendar API gives access
     to most calendar features.
   pages:
   - name: Overview
     content: &#40;== include google/foo/overview.md ==&#41;
   - name: Tutorial
     content: &#40;== include google/foo/tutorial.md ==&#41;
     subpages;
     - name: Java
       content: &#40;== include google/foo/tutorial_java.md ==&#41;
   rules:
   - selector: google.calendar.Calendar.Get
     description: >
       ...
   - selector: google.calendar.Calendar.Put
     description: >
       ...
 </code></pre>
 Documentation is provided in markdown syntax. In addition to
 standard markdown features, definition lists, tables and fenced
 code blocks are supported. Section headers can be provided and are
 interpreted relative to the section nesting of the context where
 a documentation fragment is embedded.

 Documentation from the IDL is merged with documentation defined
 via the config at normalization time, where documentation provided
 by config rules overrides IDL provided.

 A number of constructs specific to the API platform are supported
 in documentation text.

 In order to reference a proto element, the following
 notation can be used:
 <pre><code>&#91;fully.qualified.proto.name]&#91;]</code></pre>
 To override the display text used for the link, this can be used:
 <pre><code>&#91;display text]&#91;fully.qualified.proto.name]</code></pre>
 Text can be excluded from doc using the following notation:
 <pre><code>&#40;-- internal comment --&#41;</code></pre>

 A few directives are available in documentation. Note that
 directives must appear on a single line to be properly
 identified. The `include` directive includes a markdown file from
 an external source:
 <pre><code>&#40;== include path/to/file ==&#41;</code></pre>
 The `resource_for` directive marks a message to be the resource of
 a collection in REST view. If it is not specified, tools attempt
 to infer the resource from the operations in a collection:
 <pre><code>&#40;== resource_for v1.shelves.books ==&#41;</code></pre>
 The directive `suppress_warning` does not directly affect documentation
 and is documented together with service config validation.



 O
]
  RP A short summary of what the service does. Can only be provided by
 plain text.


  R

  R	

  R
=
 U0 The top level pages for the documentation set.


 U


 U

 U

 U
�
 Z'� A list of documentation rules that apply to individual API elements.

 **NOTE:** All service configuration rules follow "last one wins" order.


 Z


 Z

 Z"

 Z%&
4
 ]$' The URL to the root of documentation.


 ]

 ]	

 ]"#
�
 c� Specifies the service root url if the default one (the service name
 from the yaml file) is not suitable. This can be seen in any fully
 specified service urls as well as sections that show a base that other
 urls are relative to.


 c

 c	

 c
�
 r� Declares a single overview page. For example:
 <pre><code>documentation:
   summary: ...
   overview: &#40;== include overview.md ==&#41;
 </code></pre>
 This is a shortcut for the following declaration (using pages style):
 <pre><code>documentation:
   summary: ...
   pages:
   - name: Overview
     content: &#40;== include overview.md ==&#41;
 </code></pre>
 Note: you cannot specify both `overview` field and `pages` field.


 r

 r	

 r
W
v �J A documentation rule provides information about individual API elements.



v
�
 }� The selector is a comma-separated list of patterns. Each pattern is a
 qualified name of the element which may end in "*", indicating a wildcard.
 Wildcards are only allowed at the end and for a whole component of the
 qualified name, i.e. "foo.*" is ok, but not "foo.b*" or "foo.*.bar". A
 wildcard will match one or more components. To specify a default for all
 applicable elements, the whole pattern "*" is used.


 }

 }	

 }
3
�% Description of the selected API(s).


�

�	

�
�
�%r Deprecation description of the selected element(s). It can be provided if
 an element is marked as `deprecated`.


�

�	 

�#$
~
� �p Represents a documentation page. A page can contain subpages to represent
 nested documentation set structure.


�
�
 �� The name of the page. It will be used as an identity of the page to
 generate URI of the page, text of the link to this page in navigation,
 etc. The full page name (start from the root page name to this page
 concatenated with `.`) can be used as reference to the page in your
 documentation. For example:
 <pre><code>pages:
 - name: Tutorial
   content: &#40;== include tutorial.md ==&#41;
   subpages:
   - name: Java
     content: &#40;== include tutorial_java.md ==&#41;
 </code></pre>
 You can reference `Java` page using Markdown reference link syntax:
 `[Java][Tutorial.Java]`.


 �

 �	

 �
�
�� The Markdown content of the page. You can use <code>&#40;== include {path}
 ==&#41;</code> to include content from a Markdown file.


�

�	

�
u
�g Subpages of this page. The order of subpages specified here will be
 honored in the generated docset.


�


�

�

�bproto3
�
google/api/endpoint.proto
google.api"s
Endpoint
name (	Rname
aliases (	BRaliases
targete (	Rtarget

allow_cors (R	allowCorsBo
com.google.apiBEndpointProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 C
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 .
	
 .

 '
	
 '

 "
	
$ "
�
 ( C� `Endpoint` describes a network endpoint of a service that serves a set of
 APIs. It is commonly known as a service endpoint. A service may expose
 any number of service endpoints, and all service endpoints share the same
 service definition, such as quota limits and monitoring metrics.

 Example service configuration:

     name: library-example.googleapis.com
     endpoints:
       # Below entry makes 'google.example.library.v1.Library'
       # API be served from endpoint address library-example.googleapis.com.
       # It also allows HTTP OPTIONS calls to be passed to the backend, for
       # it to decide whether the subsequent cross-origin request is
       # allowed to proceed.
     - name: library-example.googleapis.com
       allow_cors: true



 (
3
  *& The canonical name of this endpoint.


  *

  *	

  *
�
 32� Unimplemented. Dot not use.

 DEPRECATED: This field is no longer supported. Instead of using aliases,
 please specify multiple [google.api.Endpoint][google.api.Endpoint] for each of the intended
 aliases.

 Additional names that this endpoint will be hosted on.


 3


 3

 3

 3

 31

 30
�
 :� The specification of an Internet routable address of API frontend that will
 handle requests to this [API
 Endpoint](https://cloud.google.com/apis/design/glossary). It should be
 either a valid IPv4 address or a fully-qualified domain name. For example,
 "8.8.8.8" or "myservice.appspot.com".


 :

 :	

 :
�
 B� Allowing
 [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing), aka
 cross-domain traffic, would allow the backends served from this endpoint to
 receive and respond to HTTP OPTIONS requests. The response will be used by
 the browser to determine whether the subsequent cross-origin request is
 allowed to proceed.


 B

 B

 Bbproto3
�w
google/api/error_reason.proto
google.api*�
ErrorReason
ERROR_REASON_UNSPECIFIED 
SERVICE_DISABLED
BILLING_DISABLED
API_KEY_INVALID
API_KEY_SERVICE_BLOCKED!
API_KEY_HTTP_REFERRER_BLOCKED
API_KEY_IP_ADDRESS_BLOCKED
API_KEY_ANDROID_APP_BLOCKED	
API_KEY_IOS_APP_BLOCKED
RATE_LIMIT_EXCEEDED
RESOURCE_QUOTA_EXCEEDED 
LOCATION_TAX_POLICY_VIOLATED

USER_PROJECT_DENIED
CONSUMER_SUSPENDED
CONSUMER_INVALID
SECURITY_POLICY_VIOLATED
ACCESS_TOKEN_EXPIRED#
ACCESS_TOKEN_SCOPE_INSUFFICIENT
ACCOUNT_STATE_INVALID!
ACCESS_TOKEN_TYPE_UNSUPPORTEDBp
com.google.apiBErrorReasonProtoPZCgoogle.golang.org/genproto/googleapis/api/error_reason;error_reason�GAPIJ�q
 �
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 Z
	
 Z

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
�
 " �� Defines the supported values for `google.rpc.ErrorInfo.reason` for the
 `googleapis.com` error domain. This error domain is reserved for [Service
 Infrastructure](https://cloud.google.com/service-infrastructure/docs/overview).
 For each error info of this domain, the metadata key "service" refers to the
 logical identifier of an API service, such as "pubsub.googleapis.com". The
 "consumer" refers to the entity that consumes an API Service. It typically is
 a Google project that owns the client application or the server resource,
 such as "projects/123". Other metadata keys are specific to each error
 reason. For more information, see the definition of the specific error
 reason.



 "
-
  $  Do not use this default value.


  $

  $
�
 5� The request is calling a disabled service for a consumer.

 Example of an ErrorInfo when the consumer "projects/123" contacting
 "pubsub.googleapis.com" service which is disabled:

     { "reason": "SERVICE_DISABLED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "pubsub.googleapis.com"
       }
     }

 This response indicates the "pubsub.googleapis.com" has been disabled in
 "projects/123".


 5

 5
�
 F� The request whose associated billing account is disabled.

 Example of an ErrorInfo when the consumer "projects/123" fails to contact
 "pubsub.googleapis.com" service because the associated billing account is
 disabled:

     { "reason": "BILLING_DISABLED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "pubsub.googleapis.com"
       }
     }

 This response indicates the billing account associated has been disabled.


 F

 F
�
 U� The request is denied because the provided [API
 key](https://cloud.google.com/docs/authentication/api-keys) is invalid. It
 may be in a bad format, cannot be found, or has been expired).

 Example of an ErrorInfo when the request is contacting
 "storage.googleapis.com" service with an invalid API key:

     { "reason": "API_KEY_INVALID",
       "domain": "googleapis.com",
       "metadata": {
         "service": "storage.googleapis.com",
       }
     }


 U

 U
�
 e� The request is denied because it violates [API key API
 restrictions](https://cloud.google.com/docs/authentication/api-keys#adding_api_restrictions).

 Example of an ErrorInfo when the consumer "projects/123" fails to call the
 "storage.googleapis.com" service because this service is restricted in the
 API key:

     { "reason": "API_KEY_SERVICE_BLOCKED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 e

 e
�
 u$� The request is denied because it violates [API key HTTP
 restrictions](https://cloud.google.com/docs/authentication/api-keys#adding_http_restrictions).

 Example of an ErrorInfo when the consumer "projects/123" fails to call
 "storage.googleapis.com" service because the http referrer of the request
 violates API key HTTP restrictions:

     { "reason": "API_KEY_HTTP_REFERRER_BLOCKED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com",
       }
     }


 u

 u"#
�
 �!� The request is denied because it violates [API key IP address
 restrictions](https://cloud.google.com/docs/authentication/api-keys#adding_application_restrictions).

 Example of an ErrorInfo when the consumer "projects/123" fails to call
 "storage.googleapis.com" service because the caller IP of the request
 violates API key IP address restrictions:

     { "reason": "API_KEY_IP_ADDRESS_BLOCKED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com",
       }
     }


 �

 � 
�
 �"� The request is denied because it violates [API key Android application
 restrictions](https://cloud.google.com/docs/authentication/api-keys#adding_application_restrictions).

 Example of an ErrorInfo when the consumer "projects/123" fails to call
 "storage.googleapis.com" service because the request from the Android apps
 violates the API key Android application restrictions:

     { "reason": "API_KEY_ANDROID_APP_BLOCKED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 � !
�
 �� The request is denied because it violates [API key iOS application
 restrictions](https://cloud.google.com/docs/authentication/api-keys#adding_application_restrictions).

 Example of an ErrorInfo when the consumer "projects/123" fails to call
 "storage.googleapis.com" service because the request from the iOS apps
 violates the API key iOS application restrictions:

     { "reason": "API_KEY_IOS_APP_BLOCKED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 �
�

 	��	 The request is denied because there is not enough rate quota for the
 consumer.

 Example of an ErrorInfo when the consumer "projects/123" fails to contact
 "pubsub.googleapis.com" service because consumer's rate quota usage has
 reached the maximum value set for the quota limit
 "ReadsPerMinutePerProject" on the quota metric
 "pubsub.googleapis.com/read_requests":

     { "reason": "RATE_LIMIT_EXCEEDED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "pubsub.googleapis.com",
         "quota_metric": "pubsub.googleapis.com/read_requests",
         "quota_limit": "ReadsPerMinutePerProject"
       }
     }

 Example of an ErrorInfo when the consumer "projects/123" checks quota on
 the service "dataflow.googleapis.com" and hits the organization quota
 limit "DefaultRequestsPerMinutePerOrganization" on the metric
 "dataflow.googleapis.com/default_requests".

     { "reason": "RATE_LIMIT_EXCEEDED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "dataflow.googleapis.com",
         "quota_metric": "dataflow.googleapis.com/default_requests",
         "quota_limit": "DefaultRequestsPerMinutePerOrganization"
       }
     }


 	�

 	�
�	
 
��	 The request is denied because there is not enough resource quota for the
 consumer.

 Example of an ErrorInfo when the consumer "projects/123" fails to contact
 "compute.googleapis.com" service because consumer's resource quota usage
 has reached the maximum value set for the quota limit "VMsPerProject"
 on the quota metric "compute.googleapis.com/vms":

     { "reason": "RESOURCE_QUOTA_EXCEEDED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "compute.googleapis.com",
         "quota_metric": "compute.googleapis.com/vms",
         "quota_limit": "VMsPerProject"
       }
     }

 Example of an ErrorInfo when the consumer "projects/123" checks resource
 quota on the service "dataflow.googleapis.com" and hits the organization
 quota limit "jobs-per-organization" on the metric
 "dataflow.googleapis.com/job_count".

     { "reason": "RESOURCE_QUOTA_EXCEEDED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "dataflow.googleapis.com",
         "quota_metric": "dataflow.googleapis.com/job_count",
         "quota_limit": "jobs-per-organization"
       }
     }


 
�

 
�
�
 �$� The request whose associated billing account address is in a tax restricted
 location, violates the local tax restrictions when creating resources in
 the restricted region.

 Example of an ErrorInfo when creating the Cloud Storage Bucket in the
 container "projects/123" under a tax restricted region
 "locations/asia-northeast3":

     { "reason": "LOCATION_TAX_POLICY_VIOLATED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com",
         "location": "locations/asia-northeast3"
       }
     }

 This response indicates creating the Cloud Storage Bucket in
 "locations/asia-northeast3" violates the location tax restriction.


 �

 �!#
�
 �� The request is denied because the caller does not have required permission
 on the user project "projects/123" or the user project is invalid. For more
 information, check the [userProject System
 Parameters](https://cloud.google.com/apis/docs/system-parameters).

 Example of an ErrorInfo when the caller is calling Cloud Storage service
 with insufficient permissions on the user project:

     { "reason": "USER_PROJECT_DENIED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 �
�
 �� The request is denied because the consumer "projects/123" is suspended due
 to Terms of Service(Tos) violations. Check [Project suspension
 guidelines](https://cloud.google.com/resource-manager/docs/project-suspension-guidelines)
 for more information.

 Example of an ErrorInfo when calling Cloud Storage service with the
 suspended consumer "projects/123":

     { "reason": "CONSUMER_SUSPENDED",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 �
�
 �� The request is denied because the associated consumer is invalid. It may be
 in a bad format, cannot be found, or have been deleted.

 Example of an ErrorInfo when calling Cloud Storage service with the
 invalid consumer "projects/123":

     { "reason": "CONSUMER_INVALID",
       "domain": "googleapis.com",
       "metadata": {
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 �
�
 � � The request is denied because it violates [VPC Service
 Controls](https://cloud.google.com/vpc-service-controls/docs/overview).
 The 'uid' field is a random generated identifier that customer can use it
 to search the audit log for a request rejected by VPC Service Controls. For
 more information, please refer [VPC Service Controls
 Troubleshooting](https://cloud.google.com/vpc-service-controls/docs/troubleshooting#unique-id)

 Example of an ErrorInfo when the consumer "projects/123" fails to call
 Cloud Storage service because the request is prohibited by the VPC Service
 Controls.

     { "reason": "SECURITY_POLICY_VIOLATED",
       "domain": "googleapis.com",
       "metadata": {
         "uid": "123456789abcde",
         "consumer": "projects/123",
         "service": "storage.googleapis.com"
       }
     }


 �

 �
�
 �� The request is denied because the provided access token has expired.

 Example of an ErrorInfo when the request is calling Cloud Storage service
 with an expired access token:

     { "reason": "ACCESS_TOKEN_EXPIRED",
       "domain": "googleapis.com",
       "metadata": {
         "service": "storage.googleapis.com",
         "method": "google.storage.v1.Storage.GetObject"
       }
     }


 �

 �
�
 �'� The request is denied because the provided access token doesn't have at
 least one of the acceptable scopes required for the API. Please check
 [OAuth 2.0 Scopes for Google
 APIs](https://developers.google.com/identity/protocols/oauth2/scopes) for
 the list of the OAuth 2.0 scopes that you might need to request to access
 the API.

 Example of an ErrorInfo when the request is calling Cloud Storage service
 with an access token that is missing required scopes:

     { "reason": "ACCESS_TOKEN_SCOPE_INSUFFICIENT",
       "domain": "googleapis.com",
       "metadata": {
         "service": "storage.googleapis.com",
         "method": "google.storage.v1.Storage.GetObject"
       }
     }


 �!

 �$&
�
 �� The request is denied because the account associated with the provided
 access token is in an invalid state, such as disabled or deleted.
 For more information, see https://cloud.google.com/docs/authentication.

 Warning: For privacy reasons, the server may not be able to disclose the
 email address for some accounts. The client MUST NOT depend on the
 availability of the `email` attribute.

 Example of an ErrorInfo when the request is to the Cloud Storage API with
 an access token that is associated with a disabled or deleted [service
 account](http://cloud/iam/docs/service-accounts):

     { "reason": "ACCOUNT_STATE_INVALID",
       "domain": "googleapis.com",
       "metadata": {
         "service": "storage.googleapis.com",
         "method": "google.storage.v1.Storage.GetObject",
         "email": "user@123.iam.gserviceaccount.com"
       }
     }


 �

 �
�
 �%� The request is denied because the type of the provided access token is not
 supported by the API being called.

 Example of an ErrorInfo when the request is to the Cloud Storage API with
 an unsupported token type.

     { "reason": "ACCESS_TOKEN_TYPE_UNSUPPORTED",
       "domain": "googleapis.com",
       "metadata": {
         "service": "storage.googleapis.com",
         "method": "google.storage.v1.Storage.GetObject"
       }
     }


 �

 �"$bproto3
�
google/api/field_behavior.proto
google.api google/protobuf/descriptor.proto*�
FieldBehavior
FIELD_BEHAVIOR_UNSPECIFIED 
OPTIONAL
REQUIRED
OUTPUT_ONLY

INPUT_ONLY
	IMMUTABLE
UNORDERED_LIST
NON_EMPTY_DEFAULT:`
field_behavior.google.protobuf.FieldOptions� (2.google.api.FieldBehaviorRfieldBehaviorBp
com.google.apiBFieldBehaviorProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 Y
�
 2� Copyright 2018 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 X
	
 X

 "
	

 "

 3
	
 3

 '
	
 '

 "
	
$ "
	
 (
�
 ':� A designation of a specific field behavior (required, output only, etc.)
 in protobuf messages.

 Examples:

   string name = 1 [(google.api.field_behavior) = REQUIRED];
   State state = 1 [(google.api.field_behavior) = OUTPUT_ONLY];
   google.protobuf.Duration ttl = 1
     [(google.api.field_behavior) = INPUT_ONLY];
   google.protobuf.Timestamp expire_time = 1
     [(google.api.field_behavior) = OUTPUT_ONLY,
      (google.api.field_behavior) = IMMUTABLE];



 #


 '



 '#


 '$2


 '59
�
 0 Y� An indicator of the behavior of a given field (for example, that a field
 is required in requests, or given as output but ignored as input).
 This **does not** change the behavior in protocol buffers itself; it only
 denotes the behavior and may affect how API tooling handles the field.

 Note: This enum **may** receive new values in the future.



 0
?
  2!2 Conventional default for enums. Do not use this.


  2

  2 
�
 7� Specifically denotes a field as optional.
 While all fields in protocol buffers are optional, this may be specified
 for emphasis if appropriate.


 7


 7
�
 <� Denotes a field as required.
 This indicates that the field **must** be provided as part of the request,
 and failure to do so will cause an error (usually `INVALID_ARGUMENT`).


 <


 <
�
 B� Denotes a field as output only.
 This indicates that the field is provided in responses, but including the
 field in a request does nothing (the server *must* ignore it and
 *must not* throw an error as a result of the field's presence).


 B

 B
�
 G� Denotes a field as input only.
 This indicates that the field is provided in requests, and the
 corresponding field is not included in output.


 G

 G
�
 L� Denotes a field as immutable.
 This indicates that the field may be set once in a request to create a
 resource, but may not be changed thereafter.


 L

 L
�
 R� Denotes that a (repeated) field is an unordered list.
 This indicates that the service may provide the elements of the list
 in any arbitrary  order, rather than the order the user originally
 provided. Additionally, the list's order may or may not be stable.


 R

 R
�
 X� Denotes that this field returns a non-empty default value if not set.
 This indicates that if the user provides the empty value in a request,
 a non-empty value will be returned. The user will not be aware of what
 non-empty value to expect.


 X

 Xbproto3
�
google/api/httpbody.proto
google.apigoogle/protobuf/any.proto"w
HttpBody!
content_type (	RcontentType
data (Rdata4

extensions (2.google.protobuf.AnyR
extensionsBh
com.google.apiBHttpBodyProtoPZ;google.golang.org/genproto/googleapis/api/httpbody;httpbody��GAPIJ�
 P
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #

 
	
 

 R
	
 R

 "
	

 "

 .
	
 .

 '
	
 '

 "
	
$ "
�

 F P�
 Message that represents an arbitrary HTTP body. It should only be used for
 payload formats that can't be represented as JSON, such as raw binary or
 an HTML page.


 This message can be used both in streaming and non-streaming API methods in
 the request as well as the response.

 It can be used as a top-level request field, which is convenient if one
 wants to extract parameters from either the URL or HTTP template into the
 request fields and also want access to the raw HTTP body.

 Example:

     message GetResourceRequest {
       // A unique request id.
       string request_id = 1;

       // The raw HTTP body is bound to this field.
       google.api.HttpBody http_body = 2;

     }

     service ResourceService {
       rpc GetResource(GetResourceRequest)
         returns (google.api.HttpBody);
       rpc UpdateResource(google.api.HttpBody)
         returns (google.protobuf.Empty);

     }

 Example with streaming methods:

     service CaldavService {
       rpc GetCalendar(stream google.api.HttpBody)
         returns (stream google.api.HttpBody);
       rpc UpdateCalendar(stream google.api.HttpBody)
         returns (stream google.api.HttpBody);

     }

 Use of this type only changes how the request and response bodies are
 handled, all other features will continue to work unchanged.



 F
Z
  HM The HTTP Content-Type header value specifying the content type of the body.


  H

  H	

  H
<
 K/ The HTTP request/response body as raw binary.


 K

 K

 K
m
 O.` Application specific response metadata. Must be set in the first response
 for streaming APIs.


 O


 O

 O)

 O,-bproto3
�
google/api/log.proto
google.apigoogle/api/label.proto"�
LogDescriptor
name (	Rname3
labels (2.google.api.LabelDescriptorRlabels 
description (	Rdescription!
display_name (	RdisplayNameBj
com.google.apiBLogProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 5
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
   

 \
	
 \

 "
	

 "

 )
	
 )

 '
	
 '

 "
	
$ "
�
 " 5� A description of a log type. Example in YAML format:

     - name: library.googleapis.com/activity_history
       description: The history of borrowing and returning library items.
       display_name: Activity
       labels:
       - key: /customer_id
         description: Identifier of a library customer



 "
�
  '� The name of the log. It must be less than 512 characters long and can
 include the following characters: upper- and lower-case alphanumeric
 characters [A-Za-z0-9], and punctuation characters including
 slash, underscore, hyphen, period [/_-.].


  '

  '	

  '
�
 ,&� The set of labels that are available to describe a specific log entry.
 Runtime requests that contain labels not specified here are
 considered invalid.


 ,


 ,

 ,!

 ,$%
�
 0s A human-readable description of this log. This information appears in
 the documentation and can contain details.


 0

 0	

 0
{
 4n The human-readable name for this log. This information appears on
 the user interface and should be concise.


 4

 4	

 4bproto3
�
google/api/logging.proto
google.api"�
Logging[
producer_destinations (2&.google.api.Logging.LoggingDestinationRproducerDestinations[
consumer_destinations (2&.google.api.Logging.LoggingDestinationRconsumerDestinationsW
LoggingDestination-
monitored_resource (	RmonitoredResource
logs (	RlogsBn
com.google.apiBLoggingProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 O
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
�
 5 O� Logging configuration of the service.

 The following example shows how to configure logs to be sent to the
 producer and consumer projects. In the example, the `activity_history`
 log is sent to both the producer and consumer projects, whereas the
 `purchase_history` log is only sent to the producer project.

     monitored_resources:
     - type: library.googleapis.com/branch
       labels:
       - key: /city
         description: The city where the library branch is located in.
       - key: /name
         description: The name of the branch.
     logs:
     - name: activity_history
       labels:
       - key: /customer_id
     - name: purchase_history
     logging:
       producer_destinations:
       - monitored_resource: library.googleapis.com/branch
         logs:
         - activity_history
         - purchase_history
       consumer_destinations:
       - monitored_resource: library.googleapis.com/branch
         logs:
         - activity_history



 5
p
  8Bb Configuration of a specific logging destination (the producer project
 or the consumer project).


  8

�
   ;"� The monitored resource type. The type must be defined in the
 [Service.monitored_resources][google.api.Service.monitored_resources] section.


   ;


   ;

   ; !
�
  A� Names of the logs to be sent to this destination. Each name must
 be defined in the [Service.logs][google.api.Service.logs] section. If the log name is
 not a domain scoped name, it will be automatically prefixed with
 the service name followed by "/".


  A

  A

  A

  A
�
  H8� Logging configurations for sending logs to the producer project.
 There can be multiple producer destinations, each one must have a
 different monitored resource type. A log can be used in at most
 one producer destination.


  H


  H

  H3

  H67
�
 N8� Logging configurations for sending logs to the consumer project.
 There can be multiple consumer destinations, each one must have a
 different monitored resource type. A log can be used in at most
 one consumer destination.


 N


 N

 N3

 N67bproto3
�"
google/protobuf/struct.protogoogle.protobuf"�
Struct;
fields (2#.google.protobuf.Struct.FieldsEntryRfieldsQ
FieldsEntry
key (	Rkey,
value (2.google.protobuf.ValueRvalue:8"�
Value;

null_value (2.google.protobuf.NullValueH R	nullValue#
number_value (H RnumberValue#
string_value (	H RstringValue

bool_value (H R	boolValue<
struct_value (2.google.protobuf.StructH RstructValue;

list_value (2.google.protobuf.ListValueH R	listValueB
kind";
	ListValue.
values (2.google.protobuf.ValueRvalues*
	NullValue

NULL_VALUE B
com.google.protobufBStructProtoPZ/google.golang.org/protobuf/types/known/structpb��GPB�Google.Protobuf.WellKnownTypesJ�
 ^
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# 
	
# 

$ F
	
$ F

% ,
	
% ,

& ,
	
& ,

' "
	

' "

( !
	
$( !
�
 2 5� `Struct` represents a structured data value, consisting of fields
 which map to dynamically typed values. In some languages, `Struct`
 might be supported by a native representation. For example, in
 scripting languages like JS a struct is represented as an
 object. The details of that representation are described together
 with the proto support for the language.

 The JSON representation for `Struct` is JSON object.



 2
9
  4 , Unordered map of dynamically typed values.


  4

  4

  4
�
= M� `Value` represents a dynamically typed value which can be either
 null, a number, a string, a boolean, a recursive struct value, or a
 list of values. A producer of value is expected to set one of these
 variants. Absence of any variant indicates an error.

 The JSON representation for `Value` is JSON value.



=
"
 ?L The kind of value.


 ?
'
 A Represents a null value.


 A

 A

 A
)
C Represents a double value.


C


C

C
)
E Represents a string value.


E


E

E
*
G Represents a boolean value.


G

G	

G
-
I  Represents a structured value.


I


I

I
-
K  Represents a repeated `Value`.


K

K

K
�
 S V� `NullValue` is a singleton enumeration to represent the null value for the
 `Value` type union.

  The JSON representation for `NullValue` is JSON `null`.



 S

  U Null value.


  U

  U
�
[ ^v `ListValue` is a wrapper around a repeated field of values.

 The JSON representation for `ListValue` is JSON array.



[
:
 ]- Repeated field of dynamically typed values.


 ]


 ]

 ]

 ]bproto3
�0
#google/api/monitored_resource.proto
google.apigoogle/api/label.protogoogle/api/launch_stage.protogoogle/protobuf/struct.proto"�
MonitoredResourceDescriptor
name (	Rname
type (	Rtype!
display_name (	RdisplayName 
description (	Rdescription3
labels (2.google.api.LabelDescriptorRlabels:
launch_stage (2.google.api.LaunchStageRlaunchStage"�
MonitoredResource
type (	RtypeA
labels (2).google.api.MonitoredResource.LabelsEntryRlabels9
LabelsEntry
key (	Rkey
value (	Rvalue:8"�
MonitoredResourceMetadata<
system_labels (2.google.protobuf.StructRsystemLabelsV
user_labels (25.google.api.MonitoredResourceMetadata.UserLabelsEntryR
userLabels=
UserLabelsEntry
key (	Rkey
value (	Rvalue:8By
com.google.apiBMonitoredResourceProtoPZCgoogle.golang.org/genproto/googleapis/api/monitoredres;monitoredres��GAPIJ�)
 u
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
   
	
 '
	
 &

 
	
 

 Z
	
 Z

 "
	

 "

 7
	
 7

 '
	
 '

 "
	
$ "
�
 ' E� An object that describes the schema of a [MonitoredResource][google.api.MonitoredResource] object using a
 type name and a set of labels.  For example, the monitored resource
 descriptor for Google Compute Engine VM instances has a type of
 `"gce_instance"` and specifies the use of the labels `"instance_id"` and
 `"zone"` to identify particular VM instances.

 Different APIs can support different monitored resource types. APIs generally
 provide a `list` method that returns the monitored resource descriptors used
 by the API.




 '#
�
  .� Optional. The resource name of the monitored resource descriptor:
 `"projects/{project_id}/monitoredResourceDescriptors/{type}"` where
 {type} is the value of the `type` field in this object and
 {project_id} is a project ID that provides API-specific context for
 accessing the type.  APIs that do not use project information can use the
 resource name format `"monitoredResourceDescriptors/{type}"`.


  .

  .	

  .
�
 2 Required. The monitored resource type. For example, the type
 `"cloudsql_database"` represents databases in Google Cloud SQL.


 2

 2	

 2
�
 8� Optional. A concise name for the monitored resource type that might be
 displayed in user interfaces. It should be a Title Cased Noun Phrase,
 without any article or other determiners. For example,
 `"Google Cloud SQL Database"`.


 8

 8	

 8
t
 <g Optional. A detailed description of the monitored resource type that might
 be used in documentation.


 <

 <	

 <
�
 A&� Required. A set of labels used to describe instances of this monitored
 resource type. For example, an individual Google Cloud SQL database is
 identified by values for the labels `"database_id"` and `"zone"`.


 A


 A

 A!

 A$%
O
 DB Optional. The launch stage of the monitored resource definition.


 D

 D

 D
�
T ^� An object representing a resource that can be used for monitoring, logging,
 billing, or other purposes. Examples include virtual machine instances,
 databases, and storage devices such as disks. The `type` field identifies a
 [MonitoredResourceDescriptor][google.api.MonitoredResourceDescriptor] object that describes the resource's
 schema. Information in the `labels` field identifies the actual resource and
 its attributes according to the schema. For example, a particular Compute
 Engine VM instance could be represented by the following object, because the
 [MonitoredResourceDescriptor][google.api.MonitoredResourceDescriptor] for `"gce_instance"` has labels
 `"instance_id"` and `"zone"`:

     { "type": "gce_instance",
       "labels": { "instance_id": "12345678901234",
                   "zone": "us-central1-a" }}



T
�
 X� Required. The monitored resource type. This field must match
 the `type` field of a [MonitoredResourceDescriptor][google.api.MonitoredResourceDescriptor] object. For
 example, the type of a Compute Engine VM instance is `gce_instance`.


 X

 X	

 X
�
]!� Required. Values for all of the labels listed in the associated monitored
 resource descriptor. For example, Compute Engine VM instances use the
 labels `"project_id"`, `"instance_id"`, and `"zone"`.


]

]

] 
�
f u� Auxiliary metadata for a [MonitoredResource][google.api.MonitoredResource] object.
 [MonitoredResource][google.api.MonitoredResource] objects contain the minimum set of information to
 uniquely identify a monitored resource instance. There is some other useful
 auxiliary metadata. Monitoring and Logging use an ingestion
 pipeline to extract metadata for cloud resources of all types, and store
 the metadata in this message.



f!
�
 q+� Output only. Values for predefined system metadata labels.
 System labels are a kind of metadata extracted by Google, including
 "machine_image", "vpc", "subnet_id",
 "security_group", "name", etc.
 System label values can be only strings, Boolean values, or a list of
 strings. For example:

     { "name": "my-test-instance",
       "security_group": ["a", "b", "c"],
       "spot_instance": false }


 q

 q&

 q)*
B
t&5 Output only. A map of user-defined metadata labels.


t

t!

t$%bproto3
�$
google/api/monitoring.proto
google.api"�

Monitoringa
producer_destinations (2,.google.api.Monitoring.MonitoringDestinationRproducerDestinationsa
consumer_destinations (2,.google.api.Monitoring.MonitoringDestinationRconsumerDestinations`
MonitoringDestination-
monitored_resource (	RmonitoredResource
metrics (	RmetricsBq
com.google.apiBMonitoringProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ� 
 h
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 0
	
 0

 '
	
 '

 "
	
$ "
�
 L h� Monitoring configuration of the service.

 The example below shows how to configure monitored resources and metrics
 for monitoring. In the example, a monitored resource and two metrics are
 defined. The `library.googleapis.com/book/returned_count` metric is sent
 to both producer and consumer projects, whereas the
 `library.googleapis.com/book/num_overdue` metric is only sent to the
 consumer project.

     monitored_resources:
     - type: library.googleapis.com/Branch
       display_name: "Library Branch"
       description: "A branch of a library."
       launch_stage: GA
       labels:
       - key: resource_container
         description: "The Cloud container (ie. project id) for the Branch."
       - key: location
         description: "The location of the library branch."
       - key: branch_id
         description: "The id of the branch."
     metrics:
     - name: library.googleapis.com/book/returned_count
       display_name: "Books Returned"
       description: "The count of books that have been returned."
       launch_stage: GA
       metric_kind: DELTA
       value_type: INT64
       unit: "1"
       labels:
       - key: customer_id
         description: "The id of the customer."
     - name: library.googleapis.com/book/num_overdue
       display_name: "Books Overdue"
       description: "The current number of overdue books."
       launch_stage: GA
       metric_kind: GAUGE
       value_type: INT64
       unit: "1"
       labels:
       - key: customer_id
         description: "The id of the customer."
     monitoring:
       producer_destinations:
       - monitored_resource: library.googleapis.com/Branch
         metrics:
         - library.googleapis.com/book/returned_count
       consumer_destinations:
       - monitored_resource: library.googleapis.com/Branch
         metrics:
         - library.googleapis.com/book/returned_count
         - library.googleapis.com/book/num_overdue



 L
s
  OWe Configuration of a specific monitoring destination (the producer project
 or the consumer project).


  O

�
   R"� The monitored resource type. The type must be defined in
 [Service.monitored_resources][google.api.Service.monitored_resources] section.


   R


   R

   R !
�
  V � Types of the metrics to report to this monitoring destination.
 Each type must be defined in [Service.metrics][google.api.Service.metrics] section.


  V

  V

  V

  V
�
  _;� Monitoring configurations for sending metrics to the producer project.
 There can be multiple producer destinations. A monitored resource type may
 appear in multiple monitoring destinations if different aggregations are
 needed for different sets of metrics associated with that monitored
 resource type. A monitored resource and metric pair may only be used once
 in the Monitoring configuration.


  _


  _ 

  _!6

  _9:
�
 g;� Monitoring configurations for sending metrics to the consumer project.
 There can be multiple consumer destinations. A monitored resource type may
 appear in multiple monitoring destinations if different aggregations are
 needed for different sets of metrics associated with that monitored
 resource type. A monitored resource and metric pair may only be used once
 in the Monitoring configuration.


 g


 g 

 g!6

 g9:bproto3
�=
google/api/quota.proto
google.api"r
Quota.
limits (2.google.api.QuotaLimitRlimits9
metric_rules (2.google.api.MetricRuleRmetricRules"�

MetricRule
selector (	RselectorJ
metric_costs (2'.google.api.MetricRule.MetricCostsEntryRmetricCosts>
MetricCostsEntry
key (	Rkey
value (Rvalue:8"�

QuotaLimit
name (	Rname 
description (	Rdescription#
default_limit (RdefaultLimit
	max_limit (RmaxLimit
	free_tier (RfreeTier
duration (	Rduration
metric (	Rmetric
unit	 (	Runit:
values
 (2".google.api.QuotaLimit.ValuesEntryRvalues!
display_name (	RdisplayName9
ValuesEntry
key (	Rkey
value (Rvalue:8Bl
com.google.apiB
QuotaProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�7
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 +
	
 +

 '
	
 '

 "
	
$ "
�
 K R� Quota configuration helps to achieve fairness and budgeting in service
 usage.

 The metric based quota configuration works this way:
 - The service configuration defines a set of metrics.
 - For API calls, the quota.metric_rules maps methods to metrics with
   corresponding costs.
 - The quota.limits defines limits on the metrics, which will be used for
   quota checks at runtime.

 An example quota configuration in yaml format:

    quota:
      limits:

      - name: apiWriteQpsPerProject
        metric: library.googleapis.com/write_calls
        unit: "1/min/{project}"  # rate limit for consumer projects
        values:
          STANDARD: 10000


      # The metric rules bind all methods to the read_calls metric,
      # except for the UpdateBook and DeleteBook methods. These two methods
      # are mapped to the write_calls metric, with the UpdateBook method
      # consuming at twice rate as the DeleteBook method.
      metric_rules:
      - selector: "*"
        metric_costs:
          library.googleapis.com/read_calls: 1
      - selector: google.example.library.v1.LibraryService.UpdateBook
        metric_costs:
          library.googleapis.com/write_calls: 2
      - selector: google.example.library.v1.LibraryService.DeleteBook
        metric_costs:
          library.googleapis.com/write_calls: 1

  Corresponding Metric definition:

      metrics:
      - name: library.googleapis.com/read_calls
        display_name: Read requests
        metric_kind: DELTA
        value_type: INT64

      - name: library.googleapis.com/write_calls
        display_name: Write requests
        metric_kind: DELTA
        value_type: INT64





 K
@
  M!3 List of `QuotaLimit` definitions for the service.


  M


  M

  M

  M 
l
 Q'_ List of `MetricRule` definitions, each one mapping a selected method to one
 or more metrics.


 Q


 Q

 Q"

 Q%&
�
V c� Bind API methods to metrics. Binding a method to a metric causes that
 metric's configured quota behaviors to apply to the method call.



V
�
 Z� Selects the methods to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 Z

 Z	

 Z
�
b&� Metrics to update when the selected methods are called, and the associated
 cost applied to each metric.

 The key of the map is the metric name, and the values are the amount
 increased for the metric against which the quota limits are defined.
 The value must not be negative.


b

b!

b$%
�
h �� `QuotaLimit` defines a specific limit that applies over a specified duration
 for a limit type. There can be at most one limit for a duration and limit
 type combination defined within a `QuotaGroup`.



h
�
 o� Name of the quota limit.

 The name must be provided, and it must be unique within the service. The
 name can only include alphanumeric characters as well as '-'.

 The maximum length of the limit name is 64 characters.


 o

 o	

 o
�
t� Optional. User-visible, extended description for this quota limit.
 Should be used only when more context is needed to understand this limit
 than provided by the limit's display name (see: `display_name`).


t

t	

t
�
�� Default number of tokens that can be consumed during the specified
 duration. This is the number of tokens assigned when a client
 application developer activates the service for his/her project.

 Specifying a value of 0 will block all requests. This can be used if you
 are provisioning quota to selected consumers and blocking others.
 Similarly, a value of -1 will indicate an unlimited quota. No other
 negative values are allowed.

 Used by group-based quotas only.


�

�

�
�
�� Maximum number of tokens that can be consumed during the specified
 duration. Client application developers can override the default limit up
 to this maximum. If specified, this value cannot be set to a value less
 than the default limit. If not specified, it is set to the default limit.

 To allow clients to apply overrides with no upper bound, set this to -1,
 indicating unlimited maximum quota.

 Used by group-based quotas only.


�

�

�
�
�� Free tier value displayed in the Developers Console for this limit.
 The free tier is the number of tokens that will be subtracted from the
 billed amount when billing is enabled.
 This field can only be set on a limit with duration "1d", in a billable
 group; it is invalid on any other limit. If this field is not set, it
 defaults to 0, indicating that there is no free tier for this service.

 Used by group-based quotas only.


�

�

�
v
�h Duration of this limit in textual notation. Must be "100s" or "1d".

 Used by group-based quotas only.


�

�	

�
�
�� The name of the metric this quota limit applies to. The quota limits with
 the same metric will be checked together during runtime. The metric must be
 defined within the service config.


�

�	

�
�
�� Specify the unit of the quota limit. It uses the same syntax as
 [Metric.unit][]. The supported unit kinds are determined by the quota
 backend system.

 Here are some examples:
 * "1/min/{project}" for quota per minute per project.

 Note: the order of unit components is insignificant.
 The "1" at the beginning is required to follow the metric unit syntax.


�

�	

�
�
�!� Tiered limit values. You must specify this as a key:value pair, with an
 integer value that is the maximum number of requests allowed for the
 specified unit. Currently only STANDARD is supported.


�

�

� 
�
	�� User-visible display name for this limit.
 Optional. If not set, the UI will provide a default display name based on
 the quota configuration. This field can be used to override the default
 display name generated from the configuration.


	�

	�	

	�bproto3
�I
google/api/resource.proto
google.api google/protobuf/descriptor.proto"�
ResourceDescriptor
type (	Rtype
pattern (	Rpattern

name_field (	R	nameField@
history (2&.google.api.ResourceDescriptor.HistoryRhistory
plural (	Rplural
singular (	Rsingular:
style
 (2$.google.api.ResourceDescriptor.StyleRstyle"[
History
HISTORY_UNSPECIFIED 
ORIGINALLY_SINGLE_PATTERN
FUTURE_MULTI_PATTERN"8
Style
STYLE_UNSPECIFIED 
DECLARATIVE_FRIENDLY"F
ResourceReference
type (	Rtype

child_type (	R	childType:l
resource_reference.google.protobuf.FieldOptions� (2.google.api.ResourceReferenceRresourceReference:n
resource_definition.google.protobuf.FileOptions� (2.google.api.ResourceDescriptorRresourceDefinition:\
resource.google.protobuf.MessageOptions� (2.google.api.ResourceDescriptorRresourceBn
com.google.apiBResourceProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�A
 �
�
 2� Copyright 2018 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 
	
 

 X
	
 X

 "
	

 "

 .
	
 .

 '
	
 '

 "
	
$ "
	
 
[
 9P An annotation that describes a resource reference, see
 [ResourceReference][].



 #


 


 1


 48
	
! %
}
$Dr An annotation that describes a resource definition without a corresponding
 message; see [ResourceDescriptor][].



!"


$



$(


$)<


$?C
	
' +
]
*0R An annotation that describes a resource definition, see
 [ResourceDescriptor][].



'%


*


* (


*+/
�
 \ �� A simple descriptor of a resource type.

 ResourceDescriptor annotates a resource message (either by means of a
 protobuf annotation or use in the service config), and associates the
 resource's schema, the resource type, and the pattern of the resource name.

 Example:

     message Topic {
       // Indicates this message defines a resource schema.
       // Declares the resource type in the format of {service}/{kind}.
       // For Kubernetes resources, the format is {api group}/{kind}.
       option (google.api.resource) = {
         type: "pubsub.googleapis.com/Topic"
         pattern: "projects/{project}/topics/{topic}"
       };
     }

 The ResourceDescriptor Yaml config will look like:

     resources:
     - type: "pubsub.googleapis.com/Topic"
       pattern: "projects/{project}/topics/{topic}"

 Sometimes, resources have multiple patterns, typically because they can
 live under multiple parents.

 Example:

     message LogEntry {
       option (google.api.resource) = {
         type: "logging.googleapis.com/LogEntry"
         pattern: "projects/{project}/logs/{log}"
         pattern: "folders/{folder}/logs/{log}"
         pattern: "organizations/{organization}/logs/{log}"
         pattern: "billingAccounts/{billing_account}/logs/{log}"
       };
     }

 The ResourceDescriptor Yaml config will look like:

     resources:
     - type: 'logging.googleapis.com/LogEntry'
       pattern: "projects/{project}/logs/{log}"
       pattern: "folders/{folder}/logs/{log}"
       pattern: "organizations/{organization}/logs/{log}"
       pattern: "billingAccounts/{billing_account}/logs/{log}"



 \
a
  _kS A description of the historical or future-looking state of the
 resource pattern.


  _
#
   a The "unset" value.


   a

   a
y
  e"j The resource originally had one pattern and launched as such, and
 additional patterns were added later.


  e

  e !
�
  j� The resource has one pattern, but the API owner expects to add more
 later. (This is the inverse of ORIGINALLY_SINGLE_PATTERN, and prevents
 that from being necessary once there are multiple patterns.)


  j

  j
Z
 n{L A flag representing a specific style that a resource claims to conform to.


 n
3
  p$ The unspecified value. Do not use.


  p

  p
�
 z� This resource is intended to be "declarative-friendly".

 Declarative-friendly resources must be more strictly consistent, and
 setting this to true communicates to tools that this resource should
 adhere to declarative-friendly expectations.

 Note: This is used by the API linter (linter.aip.dev) to enable
 additional checks.


 z

 z
�
  �� The resource type. It must be in the format of
 {service_name}/{resource_type_kind}. The `resource_type_kind` must be
 singular and must not include version numbers.

 Example: `storage.googleapis.com/Bucket`

 The value of the resource_type_kind must follow the regular expression
 /[A-Za-z][a-zA-Z0-9]+/. It should start with an upper case character and
 should use PascalCase (UpperCamelCase). The maximum number of
 characters allowed for the `resource_type_kind` is 100.


  �

  �	

  �
�
 �� Optional. The relative resource name pattern associated with this resource
 type. The DNS prefix of the full resource name shouldn't be specified here.

 The path pattern must follow the syntax, which aligns with HTTP binding
 syntax:

     Template = Segment { "/" Segment } ;
     Segment = LITERAL | Variable ;
     Variable = "{" LITERAL "}" ;

 Examples:

     - "projects/{project}/topics/{topic}"
     - "projects/{project}/knowledgeBases/{knowledge_base}"

 The components in braces correspond to the IDs for each resource in the
 hierarchy. It is expected that, if multiple patterns are provided,
 the same component name (e.g. "project") refers to IDs of the same
 type of resource.


 �


 �

 �

 �
�
 �y Optional. The field on the resource that designates the resource name
 field. If omitted, this is assumed to be "name".


 �

 �	

 �
�
 �� Optional. The historical or future-looking state of the resource pattern.

 Example:

     // The InspectTemplate message originally only supported resource
     // names with organization, and project was added later.
     message InspectTemplate {
       option (google.api.resource) = {
         type: "dlp.googleapis.com/InspectTemplate"
         pattern:
         "organizations/{organization}/inspectTemplates/{inspect_template}"
         pattern: "projects/{project}/inspectTemplates/{inspect_template}"
         history: ORIGINALLY_SINGLE_PATTERN
       };
     }


 �	

 �


 �
�
 �� The plural name used in the resource name and permission names, such as
 'projects' for the resource name of 'projects/{project}' and the permission
 name of 'cloudresourcemanager.googleapis.com/projects.get'. It is the same
 concept of the `plural` field in k8s CRD spec
 https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/

 Note: The plural form is required even for singleton resources. See
 https://aip.dev/156


 �

 �	

 �
�
 �� The same concept of the `singular` field in k8s CRD spec
 https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/
 Such as "project" for the `resourcemanager.googleapis.com/Project` type.


 �

 �	

 �
�
 �� Style flag(s) for this resource.
 These indicate that a resource is expected to conform to a given
 style. See the specific style flags for additional information.


 �


 �

 �

 �
i
� �[ Defines a proto annotation that describes a string field that refers to
 an API resource.


�
�
 �� The resource type that the annotated field references.

 Example:

     message Subscription {
       string topic = 2 [(google.api.resource_reference) = {
         type: "pubsub.googleapis.com/Topic"
       }];
     }

 Occasionally, a field may reference an arbitrary resource. In this case,
 APIs use the special value * in their resource reference.

 Example:

     message GetIamPolicyRequest {
       string resource = 2 [(google.api.resource_reference) = {
         type: "*"
       }];
     }


 �

 �	

 �
�
�� The resource type of a child collection that the annotated field
 references. This is useful for annotating the `parent` field that
 doesn't have a fixed resource type.

 Example:

     message ListLogEntriesRequest {
       string parent = 1 [(google.api.resource_reference) = {
         child_type: "logging.googleapis.com/LogEntry"
       };
     }


�

�	

�bproto3
�o
google/api/routing.proto
google.api google/protobuf/descriptor.proto"Z
RoutingRuleK
routing_parameters (2.google.api.RoutingParameterRroutingParameters"M
RoutingParameter
field (	Rfield#
path_template (	RpathTemplate:T
routing.google.protobuf.MethodOptions�ʼ" (2.google.api.RoutingRuleRroutingBj
com.google.apiBRoutingProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�l
 �
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 X
	
 X

 "
	

 "

 -
	
 -

 '
	
 '

 "
	
$ "
	
 

 , See RoutingRule.



 $


 


  


 #+
�N
 � ��N Specifies the routing information that should be sent along with the request
 in the form of routing header.
 **NOTE:** All service configuration rules follow the "last one wins" order.

 The examples below will apply to an RPC which has the following request type:

 Message Definition:

     message Request {
       // The name of the Table
       // Values can be of the following formats:
       // - `projects/<project>/tables/<table>`
       // - `projects/<project>/instances/<instance>/tables/<table>`
       // - `region/<region>/zones/<zone>/tables/<table>`
       string table_name = 1;

       // This value specifies routing for replication.
       // It can be in the following formats:
       // - `profiles/<profile_id>`
       // - a legacy `profile_id` that can be any string
       string app_profile_id = 2;
     }

 Example message:

     {
       table_name: projects/proj_foo/instances/instance_bar/table/table_baz,
       app_profile_id: profiles/prof_qux
     }

 The routing header consists of one or multiple key-value pairs. Every key
 and value must be percent-encoded, and joined together in the format of
 `key1=value1&key2=value2`.
 In the examples below I am skipping the percent-encoding for readablity.

 Example 1

 Extracting a field from the request to put into the routing header
 unchanged, with the key equal to the field name.

 annotation:

     option (google.api.routing) = {
       // Take the `app_profile_id`.
       routing_parameters {
         field: "app_profile_id"
       }
     };

 result:

     x-goog-request-params: app_profile_id=profiles/prof_qux

 Example 2

 Extracting a field from the request to put into the routing header
 unchanged, with the key different from the field name.

 annotation:

     option (google.api.routing) = {
       // Take the `app_profile_id`, but name it `routing_id` in the header.
       routing_parameters {
         field: "app_profile_id"
         path_template: "{routing_id=**}"
       }
     };

 result:

     x-goog-request-params: routing_id=profiles/prof_qux

 Example 3

 Extracting a field from the request to put into the routing
 header, while matching a path template syntax on the field's value.

 NB: it is more useful to send nothing than to send garbage for the purpose
 of dynamic routing, since garbage pollutes cache. Thus the matching.

 Sub-example 3a

 The field matches the template.

 annotation:

     option (google.api.routing) = {
       // Take the `table_name`, if it's well-formed (with project-based
       // syntax).
       routing_parameters {
         field: "table_name"
         path_template: "{table_name=projects/*/instances/*/**}"
       }
     };

 result:

     x-goog-request-params:
     table_name=projects/proj_foo/instances/instance_bar/table/table_baz

 Sub-example 3b

 The field does not match the template.

 annotation:

     option (google.api.routing) = {
       // Take the `table_name`, if it's well-formed (with region-based
       // syntax).
       routing_parameters {
         field: "table_name"
         path_template: "{table_name=regions/*/zones/*/**}"
       }
     };

 result:

     <no routing header will be sent>

 Sub-example 3c

 Multiple alternative conflictingly named path templates are
 specified. The one that matches is used to construct the header.

 annotation:

     option (google.api.routing) = {
       // Take the `table_name`, if it's well-formed, whether
       // using the region- or projects-based syntax.

       routing_parameters {
         field: "table_name"
         path_template: "{table_name=regions/*/zones/*/**}"
       }
       routing_parameters {
         field: "table_name"
         path_template: "{table_name=projects/*/instances/*/**}"
       }
     };

 result:

     x-goog-request-params:
     table_name=projects/proj_foo/instances/instance_bar/table/table_baz

 Example 4

 Extracting a single routing header key-value pair by matching a
 template syntax on (a part of) a single request field.

 annotation:

     option (google.api.routing) = {
       // Take just the project id from the `table_name` field.
       routing_parameters {
         field: "table_name"
         path_template: "{routing_id=projects/*}/**"
       }
     };

 result:

     x-goog-request-params: routing_id=projects/proj_foo

 Example 5

 Extracting a single routing header key-value pair by matching
 several conflictingly named path templates on (parts of) a single request
 field. The last template to match "wins" the conflict.

 annotation:

     option (google.api.routing) = {
       // If the `table_name` does not have instances information,
       // take just the project id for routing.
       // Otherwise take project + instance.

       routing_parameters {
         field: "table_name"
         path_template: "{routing_id=projects/*}/**"
       }
       routing_parameters {
         field: "table_name"
         path_template: "{routing_id=projects/*/instances/*}/**"
       }
     };

 result:

     x-goog-request-params:
     routing_id=projects/proj_foo/instances/instance_bar

 Example 6

 Extracting multiple routing header key-value pairs by matching
 several non-conflicting path templates on (parts of) a single request field.

 Sub-example 6a

 Make the templates strict, so that if the `table_name` does not
 have an instance information, nothing is sent.

 annotation:

     option (google.api.routing) = {
       // The routing code needs two keys instead of one composite
       // but works only for the tables with the "project-instance" name
       // syntax.

       routing_parameters {
         field: "table_name"
         path_template: "{project_id=projects/*}/instances/*/**"
       }
       routing_parameters {
         field: "table_name"
         path_template: "projects/*/{instance_id=instances/*}/**"
       }
     };

 result:

     x-goog-request-params:
     project_id=projects/proj_foo&instance_id=instances/instance_bar

 Sub-example 6b

 Make the templates loose, so that if the `table_name` does not
 have an instance information, just the project id part is sent.

 annotation:

     option (google.api.routing) = {
       // The routing code wants two keys instead of one composite
       // but will work with just the `project_id` for tables without
       // an instance in the `table_name`.

       routing_parameters {
         field: "table_name"
         path_template: "{project_id=projects/*}/**"
       }
       routing_parameters {
         field: "table_name"
         path_template: "projects/*/{instance_id=instances/*}/**"
       }
     };

 result (is the same as 6a for our example message because it has the instance
 information):

     x-goog-request-params:
     project_id=projects/proj_foo&instance_id=instances/instance_bar

 Example 7

 Extracting multiple routing header key-value pairs by matching
 several path templates on multiple request fields.

 NB: note that here there is no way to specify sending nothing if one of the
 fields does not match its template. E.g. if the `table_name` is in the wrong
 format, the `project_id` will not be sent, but the `routing_id` will be.
 The backend routing code has to be aware of that and be prepared to not
 receive a full complement of keys if it expects multiple.

 annotation:

     option (google.api.routing) = {
       // The routing needs both `project_id` and `routing_id`
       // (from the `app_profile_id` field) for routing.

       routing_parameters {
         field: "table_name"
         path_template: "{project_id=projects/*}/**"
       }
       routing_parameters {
         field: "app_profile_id"
         path_template: "{routing_id=**}"
       }
     };

 result:

     x-goog-request-params:
     project_id=projects/proj_foo&routing_id=profiles/prof_qux

 Example 8

 Extracting a single routing header key-value pair by matching
 several conflictingly named path templates on several request fields. The
 last template to match "wins" the conflict.

 annotation:

     option (google.api.routing) = {
       // The `routing_id` can be a project id or a region id depending on
       // the table name format, but only if the `app_profile_id` is not set.
       // If `app_profile_id` is set it should be used instead.

       routing_parameters {
         field: "table_name"
         path_template: "{routing_id=projects/*}/**"
       }
       routing_parameters {
          field: "table_name"
          path_template: "{routing_id=regions/*}/**"
       }
       routing_parameters {
         field: "app_profile_id"
         path_template: "{routing_id=**}"
       }
     };

 result:

     x-goog-request-params: routing_id=profiles/prof_qux

 Example 9

 Bringing it all together.

 annotation:

     option (google.api.routing) = {
       // For routing both `table_location` and a `routing_id` are needed.
       //
       // table_location can be either an instance id or a region+zone id.
       //
       // For `routing_id`, take the value of `app_profile_id`
       // - If it's in the format `profiles/<profile_id>`, send
       // just the `<profile_id>` part.
       // - If it's any other literal, send it as is.
       // If the `app_profile_id` is empty, and the `table_name` starts with
       // the project_id, send that instead.

       routing_parameters {
         field: "table_name"
         path_template: "projects/*/{table_location=instances/*}/tables/*"
       }
       routing_parameters {
         field: "table_name"
         path_template: "{table_location=regions/*/zones/*}/tables/*"
       }
       routing_parameters {
         field: "table_name"
         path_template: "{routing_id=projects/*}/**"
       }
       routing_parameters {
         field: "app_profile_id"
         path_template: "{routing_id=**}"
       }
       routing_parameters {
         field: "app_profile_id"
         path_template: "profiles/{routing_id=*}"
       }
     };

 result:

     x-goog-request-params:
     table_location=instances/instance_bar&routing_id=prof_qux


 �
�
  �3� A collection of Routing Parameter specifications.
 **NOTE:** If multiple Routing Parameters describe the same key
 (via the `path_template` field or via the `field` field when
 `path_template` is not provided), "last one wins" rule
 determines which Parameter gets used.
 See the examples for more details.


  �


  �

  �.

  �12
N
� �@ A projection from an input message to the GRPC or REST header.


�
J
 �< A request field to extract the header key-value pair from.


 �

 �	

 �
�
�� A pattern matching the key-value field. Optional.
 If not specified, the whole field specified in the `field` field will be
 taken as value, and its name used as key. If specified, it MUST contain
 exactly one named segment (along with any number of unnamed segments) The
 pattern will be matched over the field specified in the `field` field, then
 if the match is successful:
 - the name of the single named segment will be used as a header name,
 - the match value of the segment will be used as a header value;
 if the match is NOT successful, nothing will be sent.

 Example:

               -- This is a field in the request message
              |   that the header value will be extracted from.
              |
              |                     -- This is the key name in the
              |                    |   routing header.
              V                    |
     field: "table_name"           v
     path_template: "projects/*/{table_location=instances/*}/tables/*"
                                                ^            ^
                                                |            |
       In the {} brackets is the pattern that --             |
       specifies what to extract from the                    |
       field as a value to be sent.                          |
                                                             |
      The string in the field must match the whole pattern --
      before brackets, inside brackets, after brackets.

 When looking at this specific example, we can see that:
 - A key-value pair with the key `table_location`
   and the value matching `instances/*` should be added
   to the x-goog-request-params routing header.
 - The value is extracted from the request message's `table_name` field
   if it matches the full pattern specified:
   `projects/*/instances/*/tables/*`.

 **NB:** If the `path_template` field is not provided, the key name is
 equal to the field name, and the whole field should be sent as a value.
 This makes the pattern for the field and the value functionally equivalent
 to `**`, and the configuration

     {
       field: "table_name"
     }

 is a functionally equivalent shorthand to:

     {
       field: "table_name"
       path_template: "{table_name=**}"
     }

 See Example 1 for more details.


�

�	

�bproto3
�	
google/api/source_info.proto
google.apigoogle/protobuf/any.proto"E

SourceInfo7
source_files (2.google.protobuf.AnyRsourceFilesBq
com.google.apiBSourceInfoProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #

 \
	
 \

 "
	

 "

 0
	
 0

 '
	
 '

 "
	
$ "
@
  4 Source information used to create a Service Config



 
7
  0* All files used during config generation.


  


  

  +

  ./bproto3
�
!google/api/system_parameter.proto
google.api"I
SystemParameters5
rules (2.google.api.SystemParameterRuleRrules"n
SystemParameterRule
selector (	Rselector;

parameters (2.google.api.SystemParameterR
parameters"v
SystemParameter
name (	Rname
http_header (	R
httpHeader.
url_query_parameter (	RurlQueryParameterBv
com.google.apiBSystemParameterProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 ^
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 5
	
 5

 '
	
 '

 "
	
$ "
�
  =� ### System parameter configuration

 A system parameter is a special kind of parameter defined by the API
 system, not by an individual API. It is typically mapped to an HTTP header
 and/or a URL query parameter. This configuration specifies which methods
 change the names of the system parameters.



 
�
  <)� Define system parameters.

 The parameters defined here will override the default parameters
 implemented by the system. If this field is missing from the service
 config, default system parameters will be used. Default system parameters
 and names is implementation-dependent.

 Example: define api key for all methods

     system_parameters
       rules:
         - selector: "*"
           parameters:
             - name: api_key
               url_query_parameter: api_key


 Example: define 2 api key names for a specific method.

     system_parameters
       rules:
         - selector: "/ListShelves"
           parameters:
             - name: api_key
               http_header: Api-Key1
             - name: api_key
               http_header: Api-Key2

 **NOTE:** All service configuration rules follow "last one wins" order.


  <


  <

  <$

  <'(
^
A NR Define a system parameter rule mapping system parameter definitions to
 methods.



A
�
 F� Selects the methods to which this rule applies. Use '*' to indicate all
 methods in all APIs.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 F

 F	

 F
�
M*� Define parameters. Multiple names may be defined for a parameter.
 For a given method call, only one of them should be used. If multiple
 names are used the behavior is implementation-dependent.
 If none of the specified names are present the behavior is
 parameter-dependent.


M


M

M%

M()
�
S ^� Define a parameter's name and location. The parameter may be passed as either
 an HTTP header or a URL query parameter, and if both are passed the behavior
 is implementation-dependent.



S
Z
 UM Define the name of the parameter, such as "api_key" . It is case sensitive.


 U

 U	

 U
]
YP Define the HTTP header name to use for the parameter. It is case
 insensitive.


Y

Y	

Y
c
]!V Define the URL query parameter name to use for the parameter. It is case
 sensitive.


]

]	

] bproto3
�
google/api/usage.proto
google.api"�
Usage"
requirements (	Rrequirements+
rules (2.google.api.UsageRuleRrulesB
producer_notification_channel (	RproducerNotificationChannel"�
	UsageRule
selector (	Rselector8
allow_unregistered_calls (RallowUnregisteredCalls0
skip_service_control (RskipServiceControlBl
com.google.apiB
UsageProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�
 ^
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 \
	
 \

 "
	

 "

 +
	
 +

 '
	
 '

 "
	
$ "
;
  3/ Configuration controlling usage of a service.



 
�
  ##� Requirements that must be satisfied before a consumer project can use the
 service. Each requirement is of the form <service.name>/<requirement-id>;
 for example 'serviceusage.googleapis.com/billing-enabled'.

 For Google APIs, a Terms of Service requirement must be included here.
 Google Cloud APIs must include "serviceusage.googleapis.com/tos/cloud".
 Other Google APIs should include
 "serviceusage.googleapis.com/tos/universal". Additional ToS can be
 included based on the business needs.


  #


  #

  #

  #!"
�
 (� A list of usage rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


 (


 (

 (

 (
�
 2+� The full resource name of a channel used for sending notifications to the
 service producer.

 Google Service Management currently only supports
 [Google Cloud Pub/Sub](https://cloud.google.com/pubsub) as a notification
 channel. To use Google Cloud Pub/Sub as the channel, this must be the name
 of a Cloud Pub/Sub topic that uses the Cloud Pub/Sub topic name format
 documented in https://cloud.google.com/pubsub/docs/overview.


 2

 2	&

 2)*
�
N ^� Usage configuration rules for the service.

 NOTE: Under development.


 Use this rule to configure unregistered calls for the service. Unregistered
 calls are calls that do not contain consumer project identity.
 (Example: calls that do not contain an API key).
 By default, API methods do not allow unregistered calls, and each method call
 must be identified by a consumer project identity. Use this rule to
 allow/disallow unregistered calls.

 Example of an API that wants to allow unregistered calls for entire service.

     usage:
       rules:
       - selector: "*"
         allow_unregistered_calls: true

 Example of a method that wants to allow unregistered calls.

     usage:
       rules:
       - selector: "google.example.library.v1.LibraryService.CreateBook"
         allow_unregistered_calls: true



N
�
 S� Selects the methods to which this rule applies. Use '*' to indicate all
 methods in all APIs.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 S

 S	

 S

W$r If true, the selected method allows unregistered calls, e.g. calls
 that don't identify any user or application.


W

W

W"#
�
] � If true, the selected method should skip service control and the control
 plane features, such as quota and billing, will not be available.
 This flag is used by Google Cloud Endpoints to bypass checks for internal
 methods, such as service health check methods.


]

]

]bproto3
�
$google/protobuf/source_context.protogoogle.protobuf",
SourceContext
	file_name (	RfileNameB�
com.google.protobufBSourceContextProtoPZ6google.golang.org/protobuf/types/known/sourcecontextpb�GPB�Google.Protobuf.WellKnownTypesJ�
 /
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# ,
	
# ,

$ 3
	
$ 3

% "
	

% "

& !
	
$& !

' M
	
' M
�
 + /w `SourceContext` represents information about the source of a
 protobuf element, like the file in which it is defined.



 +
�
  .� The path-qualified name of the .proto file that contained the associated
 protobuf element.  For example: `"google/protobuf/source_context.proto"`.


  .

  .	

  .bproto3
�F
google/protobuf/type.protogoogle.protobufgoogle/protobuf/any.proto$google/protobuf/source_context.proto"�
Type
name (	Rname.
fields (2.google.protobuf.FieldRfields
oneofs (	Roneofs1
options (2.google.protobuf.OptionRoptionsE
source_context (2.google.protobuf.SourceContextRsourceContext/
syntax (2.google.protobuf.SyntaxRsyntax"�
Field/
kind (2.google.protobuf.Field.KindRkindD
cardinality (2".google.protobuf.Field.CardinalityRcardinality
number (Rnumber
name (	Rname
type_url (	RtypeUrl
oneof_index (R
oneofIndex
packed (Rpacked1
options	 (2.google.protobuf.OptionRoptions
	json_name
 (	RjsonName#
default_value (	RdefaultValue"�
Kind
TYPE_UNKNOWN 
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"t
Cardinality
CARDINALITY_UNKNOWN 
CARDINALITY_OPTIONAL
CARDINALITY_REQUIRED
CARDINALITY_REPEATED"�
Enum
name (	Rname8
	enumvalue (2.google.protobuf.EnumValueR	enumvalue1
options (2.google.protobuf.OptionRoptionsE
source_context (2.google.protobuf.SourceContextRsourceContext/
syntax (2.google.protobuf.SyntaxRsyntax"j
	EnumValue
name (	Rname
number (Rnumber1
options (2.google.protobuf.OptionRoptions"H
Option
name (	Rname*
value (2.google.protobuf.AnyRvalue*.
Syntax
SYNTAX_PROTO2 
SYNTAX_PROTO3B{
com.google.protobufB	TypeProtoPZ-google.golang.org/protobuf/types/known/typepb��GPB�Google.Protobuf.WellKnownTypesJ�8
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  
	
 " #
	
# .

% ;
	
%% ;

& 
	
& 

' ,
	
' ,

( *
	
( *

) "
	

) "

* !
	
$* !

+ D
	
+ D
-
 . ;! A protocol buffer message type.



 .
0
  0# The fully qualified message name.


  0

  0	

  0
"
 2 The list of fields.


 2


 2

 2

 2
O
 4B The list of types appearing in `oneof` definitions in this type.


 4


 4

 4

 4
+
 6 The protocol buffer options.


 6


 6

 6

 6
"
 8# The source context.


 8

 8

 8!"
!
 : The source syntax.


 :

 :	

 :
0
> �# A single field of a message type.



>
"
 @g Basic field types.


 @
$
  B Field type unknown.


  B

  B
#
 D Field type double.


 D

 D
"
 F Field type float.


 F

 F
"
 H Field type int64.


 H

 H
#
 J Field type uint64.


 J

 J
"
 L Field type int32.


 L

 L
$
 N Field type fixed64.


 N

 N
$
 P Field type fixed32.


 P

 P
!
 R Field type bool.


 R

 R
#
 	T Field type string.


 	T

 	T
F
 
V7 Field type group. Proto2 syntax only, and deprecated.


 
V

 
V
$
 X Field type message.


 X

 X
"
 Z Field type bytes.


 Z

 Z
#
 \ Field type uint32.


 \

 \
!
 ^ Field type enum.


 ^

 ^
%
 ` Field type sfixed32.


 `

 `
%
 b Field type sfixed64.


 b

 b
#
 d Field type sint32.


 d

 d
#
 f Field type sint64.


 f

 f
C
js5 Whether a field is optional, required, or repeated.


j
5
 l& For fields with unknown cardinality.


 l

 l
%
n For optional fields.


n

n
9
p* For required fields. Proto2 syntax only.


p

p
%
r For repeated fields.


r

r

 v The field type.


 v

 v

 v
%
x The field cardinality.


x

x

x
 
z The field number.


z

z

z

| The field name.


|

|	

|
�
� The field type URL, without the scheme, for message or enumeration
 types. Example: `"type.googleapis.com/google.protobuf.Timestamp"`.




	


�
�� The index of the field type in `Type.oneofs`, for message or enumeration
 types. The first type has index 1; zero means the type is not in the list.


�

�

�
F
�8 Whether to use alternative packed wire representation.


�

�

�
,
� The protocol buffer options.


�


�

�

�
$
� The field JSON name.


�

�	

�
X
	�J The string value of the default value of this field. Proto2 syntax only.


	�

	�	

	�
%
� � Enum type definition.


�

 � Enum type name.


 �

 �	

 �
'
�# Enum value definitions.


�


�

�

�!"
(
� Protocol buffer options.


�


�

�

�
#
�# The source context.


�

�

�!"
"
� The source syntax.


�

�	

�
&
� � Enum value definition.


�
 
 � Enum value name.


 �

 �	

 �
"
� Enum value number.


�

�

�
(
� Protocol buffer options.


�


�

�

�
g
� �Y A protocol buffer option, which can be attached to a message, field,
 enumeration, etc.


�
�
 �� The option's name. For protobuf built-in options (options defined in
 descriptor.proto), this is the short name. For example, `"map_entry"`.
 For custom options, it should be the fully-qualified name. For example,
 `"google.api.http"`.


 �

 �	

 �
�
�� The option's value packed in an Any message. If the value is a primitive,
 the corresponding wrapper type defined in google/protobuf/wrappers.proto
 should be used. If the value is an enum, it should be stored as an int32
 value using the google.protobuf.Int32Value type.


�

�

�
I
 � �; The syntax in which a protocol buffer element is defined.


 �
 
  � Syntax `proto2`.


  �

  �
 
 � Syntax `proto3`.


 �

 �bproto3
�C
google/protobuf/api.protogoogle.protobuf$google/protobuf/source_context.protogoogle/protobuf/type.proto"�
Api
name (	Rname1
methods (2.google.protobuf.MethodRmethods1
options (2.google.protobuf.OptionRoptions
version (	RversionE
source_context (2.google.protobuf.SourceContextRsourceContext.
mixins (2.google.protobuf.MixinRmixins/
syntax (2.google.protobuf.SyntaxRsyntax"�
Method
name (	Rname(
request_type_url (	RrequestTypeUrl+
request_streaming (RrequestStreaming*
response_type_url (	RresponseTypeUrl-
response_streaming (RresponseStreaming1
options (2.google.protobuf.OptionRoptions/
syntax (2.google.protobuf.SyntaxRsyntax"/
Mixin
name (	Rname
root (	RrootBv
com.google.protobufBApiProtoPZ,google.golang.org/protobuf/types/known/apipb�GPB�Google.Protobuf.WellKnownTypesJ�<
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  
	
 " .
	
# $

% ;
	
%% ;

& ,
	
& ,

' )
	
' )

( "
	

( "

) !
	
$) !

* C
	
* C
�
 5 `� Api is a light-weight descriptor for an API Interface.

 Interfaces are also described as "protocol buffer services" in some contexts,
 such as by the "service" keyword in a .proto file, but they are different
 from API Services, which represent a concrete implementation of an interface
 as opposed to simply a description of methods and bindings. They are also
 sometimes simply referred to as "APIs" in other contexts, such as the name of
 this message itself. See https://cloud.google.com/apis/design/glossary for
 detailed terminology.



 5
{
  8n The fully qualified name of this interface, including package name
 followed by the interface's simple name.


  8

  8	

  8
C
 ;6 The methods of this interface, in unspecified order.


 ;


 ;

 ;

 ;
6
 >) Any metadata attached to the interface.


 >


 >

 >

 >
�
 U� A version string for this interface. If specified, must have the form
 `major-version.minor-version`, as in `1.10`. If the minor version is
 omitted, it defaults to zero. If the entire version field is empty, the
 major version is derived from the package name, as outlined below. If the
 field is not empty, the version in the package name will be verified to be
 consistent with what is provided here.

 The versioning schema uses [semantic
 versioning](http://semver.org) where the major version number
 indicates a breaking change and the minor version an additive,
 non-breaking change. Both version numbers are signals to users
 what to expect from different versions, and should be carefully
 chosen based on the product plan.

 The major version is also reflected in the package name of the
 interface, which must end in `v<major-version>`, as in
 `google.feature.v1`. For major versions 0 and 1, the suffix can
 be omitted. Zero major versions must only be used for
 experimental, non-GA interfaces.




 U

 U	

 U
[
 Y#N Source context for the protocol buffer service represented by this
 message.


 Y

 Y

 Y!"
2
 \% Included interfaces. See [Mixin][].


 \


 \

 \

 \
0
 _# The source syntax of the service.


 _

 _	

 _
=
c x1 Method represents a method of an API interface.



c
.
 e! The simple name of this method.


 e

 e	

 e
/
h" A URL of the input message type.


h

h	

h
0
k# If true, the request is streamed.


k

k

k
2
n% The URL of the output message type.


n

n	

n
1
q$ If true, the response is streamed.


q

q

q
3
t& Any metadata attached to the method.


t


t

t

t
0
w# The source syntax of this method.


w

w	

w
�
� �� Declares an API Interface to be included in this interface. The including
 interface must redeclare all the methods from the included interface, but
 documentation and options are inherited as follows:

 - If after comment and whitespace stripping, the documentation
   string of the redeclared method is empty, it will be inherited
   from the original method.

 - Each annotation belonging to the service config (http,
   visibility) which is not set in the redeclared method will be
   inherited.

 - If an http annotation is inherited, the path pattern will be
   modified as follows. Any version prefix will be replaced by the
   version of the including interface plus the [root][] path if
   specified.

 Example of a simple mixin:

     package google.acl.v1;
     service AccessControl {
       // Get the underlying ACL object.
       rpc GetAcl(GetAclRequest) returns (Acl) {
         option (google.api.http).get = "/v1/{resource=**}:getAcl";
       }
     }

     package google.storage.v2;
     service Storage {
       rpc GetAcl(GetAclRequest) returns (Acl);

       // Get a data record.
       rpc GetData(GetDataRequest) returns (Data) {
         option (google.api.http).get = "/v2/{resource=**}";
       }
     }

 Example of a mixin configuration:

     apis:
     - name: google.storage.v2.Storage
       mixins:
       - name: google.acl.v1.AccessControl

 The mixin construct implies that all methods in `AccessControl` are
 also declared with same name and request/response types in
 `Storage`. A documentation generator or annotation processor will
 see the effective `Storage.GetAcl` method after inheriting
 documentation and annotations as follows:

     service Storage {
       // Get the underlying ACL object.
       rpc GetAcl(GetAclRequest) returns (Acl) {
         option (google.api.http).get = "/v2/{resource=**}:getAcl";
       }
       ...
     }

 Note how the version in the path pattern changed from `v1` to `v2`.

 If the `root` field in the mixin is specified, it should be a
 relative path under which inherited HTTP paths are placed. Example:

     apis:
     - name: google.storage.v2.Storage
       mixins:
       - name: google.acl.v1.AccessControl
         root: acls

 This implies the following inherited HTTP annotation:

     service Storage {
       // Get the underlying ACL object.
       rpc GetAcl(GetAclRequest) returns (Acl) {
         option (google.api.http).get = "/v2/acls/{resource=**}:getAcl";
       }
       ...
     }


�
L
 �> The fully qualified name of the interface which is included.


 �

 �	

 �
[
�M If non-empty specifies a path under which inherited HTTP paths
 are rooted.


�

�	

�bproto3
�#
google/protobuf/wrappers.protogoogle.protobuf"#
DoubleValue
value (Rvalue""

FloatValue
value (Rvalue""

Int64Value
value (Rvalue"#
UInt64Value
value (Rvalue""

Int32Value
value (Rvalue"#
UInt32Value
value (Rvalue"!
	BoolValue
value (Rvalue"#
StringValue
value (	Rvalue""

BytesValue
value (RvalueB�
com.google.protobufBWrappersProtoPZ1google.golang.org/protobuf/types/known/wrapperspb��GPB�Google.Protobuf.WellKnownTypesJ�
( z
�
( 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Wrappers for primitive (non-message) types. These types are useful
 for embedding primitives in the `google.protobuf.Any` type and for places
 where we need to distinguish between the absence of a primitive
 typed field and its default value.

 These wrappers have no meaningful use within repeated fields as they lack
 the ability to detect presence on individual elements.
 These wrappers have no meaningful use within a map or a oneof since
 individual entries of a map or fields of a oneof can already detect presence.


* 

, ;
	
%, ;

- 
	
- 

. H
	
. H

/ ,
	
/ ,

0 .
	
0 .

1 "
	

1 "

2 !
	
$2 !
g
 7 :[ Wrapper message for `double`.

 The JSON representation for `DoubleValue` is JSON number.



 7
 
  9 The double value.


  9

  9	

  9
e
? BY Wrapper message for `float`.

 The JSON representation for `FloatValue` is JSON number.



?

 A The float value.


 A

 A

 A
e
G JY Wrapper message for `int64`.

 The JSON representation for `Int64Value` is JSON string.



G

 I The int64 value.


 I

 I

 I
g
O R[ Wrapper message for `uint64`.

 The JSON representation for `UInt64Value` is JSON string.



O
 
 Q The uint64 value.


 Q

 Q	

 Q
e
W ZY Wrapper message for `int32`.

 The JSON representation for `Int32Value` is JSON number.



W

 Y The int32 value.


 Y

 Y

 Y
g
_ b[ Wrapper message for `uint32`.

 The JSON representation for `UInt32Value` is JSON number.



_
 
 a The uint32 value.


 a

 a	

 a
o
g jc Wrapper message for `bool`.

 The JSON representation for `BoolValue` is JSON `true` and `false`.



g

 i The bool value.


 i

 i

 i
g
o r[ Wrapper message for `string`.

 The JSON representation for `StringValue` is JSON string.



o
 
 q The string value.


 q

 q	

 q
e
w zY Wrapper message for `bytes`.

 The JSON representation for `BytesValue` is JSON string.



w

 y The bytes value.


 y

 y

 ybproto3
�>
google/api/service.proto
google.apigoogle/api/auth.protogoogle/api/backend.protogoogle/api/billing.protogoogle/api/context.protogoogle/api/control.protogoogle/api/documentation.protogoogle/api/endpoint.protogoogle/api/http.protogoogle/api/label.protogoogle/api/log.protogoogle/api/logging.protogoogle/api/metric.proto#google/api/monitored_resource.protogoogle/api/monitoring.protogoogle/api/quota.protogoogle/api/resource.protogoogle/api/source_info.proto!google/api/system_parameter.protogoogle/api/usage.protogoogle/protobuf/any.protogoogle/protobuf/api.protogoogle/protobuf/type.protogoogle/protobuf/wrappers.proto"�	
Service
name (	Rname
title (	Rtitle.
producer_project_id (	RproducerProjectId
id! (	Rid(
apis (2.google.protobuf.ApiRapis+
types (2.google.protobuf.TypeRtypes+
enums (2.google.protobuf.EnumRenums?
documentation (2.google.api.DocumentationRdocumentation-
backend (2.google.api.BackendRbackend$
http	 (2.google.api.HttpRhttp'
quota
 (2.google.api.QuotaRquotaB
authentication (2.google.api.AuthenticationRauthentication-
context (2.google.api.ContextRcontext'
usage (2.google.api.UsageRusage2
	endpoints (2.google.api.EndpointR	endpoints-
control (2.google.api.ControlRcontrol-
logs (2.google.api.LogDescriptorRlogs6
metrics (2.google.api.MetricDescriptorRmetricsX
monitored_resources (2'.google.api.MonitoredResourceDescriptorRmonitoredResources-
billing (2.google.api.BillingRbilling-
logging (2.google.api.LoggingRlogging6

monitoring (2.google.api.MonitoringR
monitoringI
system_parameters (2.google.api.SystemParametersRsystemParameters7
source_info% (2.google.api.SourceInfoR
sourceInfoG
config_version (2.google.protobuf.UInt32ValueBRconfigVersionBn
com.google.apiBServiceProtoPZEgoogle.golang.org/genproto/googleapis/api/serviceconfig;serviceconfig�GAPIJ�/
 �
�
 2� Copyright 2015 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  
	
 "
	
 "
	
 "
	
 "
	
 (
	
 #
	
 
	
  
	
	 
	

 "
	
 !
	
 -
	
 %
	
   
	
! #
	
" &
	
# +
	
$  
	
% #
	
& #
	
' $
	
( (

* \
	
* \

+ "
	

+ "

, -
	
, -

- '
	
- '

. "
	
$. "
�
 F �� `Service` is the root object of Google service configuration schema. It
 describes basic information about a service, such as the name and the
 title, and delegates other aspects to sub-sections. Each sub-section is
 either a proto message or a repeated proto message that configures a
 specific aspect, such as auth. See each proto message definition for details.

 Example:

     type: google.api.Service
     name: calendar.googleapis.com
     title: Google Calendar API
     apis:
     - name: google.calendar.v3.Calendar
     authentication:
       providers:
       - id: google_calendar_auth
         jwks_uri: https://www.googleapis.com/oauth2/v1/certs
         issuer: https://securetoken.google.com
       rules:
       - selector: "*"
         requirements:
           provider_id: google_calendar_auth



 F
�
  K� The service name, which is a DNS-like logical identifier for the
 service, such as `calendar.googleapis.com`. The service name
 typically goes through DNS verification to make sure the owner
 of the service also owns the DNS name.


  K

  K	

  K
2
 N% The product title for this service.


 N

 N	

 N
9
 Q", The Google project that owns this service.


 Q

 Q	

 Q!
�
 W� A unique ID for a specific instance of this message, typically assigned
 by the client for tracking purpose. Must be no longer than 63 characters
 and only lower case letters, digits, '.', '_' and '-' are allowed. If
 empty, the server may choose to generate one instead.


 W

 W	

 W
�
 ^(� A list of API interfaces exported by this service. Only the `name` field
 of the [google.protobuf.Api][google.protobuf.Api] needs to be provided by the configuration
 author, as the remaining fields will be derived from the IDL during the
 normalization process. It is an error to specify an API interface here
 which cannot be resolved against the associated IDL files.


 ^


 ^

 ^#

 ^&'
�
 h*� A list of all proto message types included in this API service.
 Types referenced directly or indirectly by the `apis` are
 automatically included.  Messages which are not referenced but
 shall be included, such as types used by the `google.protobuf.Any` type,
 should be listed here by name. Example:

     types:
     - name: google.protobuf.Int32


 h


 h

 h %

 h()
�
 q*� A list of all enum types included in this API service.  Enums
 referenced directly or indirectly by the `apis` are automatically
 included.  Enums which are not referenced but shall be included
 should be listed here by name. Example:

     enums:
     - name: google.someapi.v1.SomeEnum


 q


 q

 q %

 q()
,
 t" Additional API documentation.


 t

 t

 t !
)
 w API backend configuration.


 w	

 w


 w
"
 	z HTTP configuration.


 	z

 	z

 	z
#
 
} Quota configuration.


 
}

 
}

 
}
#
 �% Auth configuration.


 �

 �

 �"$
&
 � Context configuration.


 �	

 �


 �
@
 �2 Configuration controlling usage of this service.


 �

 �

 �
�
 �#� Configuration for network endpoints.  If this is empty, then an endpoint
 with the same name as the service is automatically generated to service all
 defined APIs.


 �


 �

 �

 � "
<
 �. Configuration for the service control plane.


 �	

 �


 �
6
 �#( Defines the logs used by this service.


 �


 �

 �

 � "
9
 �)+ Defines the metrics used by this service.


 �


 �

 �#

 �&(
�
 �@� Defines the monitored resources used by this service. This is required
 by the [Service.monitoring][google.api.Service.monitoring] and [Service.logging][google.api.Service.logging] configurations.


 �


 �&

 �':

 �=?
&
 � Billing configuration.


 �	

 �


 �
&
 � Logging configuration.


 �	

 �


 �
)
 � Monitoring configuration.


 �

 �

 �
/
 �*! System parameter configuration.


 �

 �$

 �')
X
 �J Output only. The source information for this configuration if available.


 �

 �

 �
�
 �Fy Obsolete. Do not use.

 This field has no semantic meaning. The service config compiler always
 sets this field to `3`.


 �

 �,

 �/1

 �2E

 �3Dbproto3
� 
google/api/visibility.proto
google.api google/protobuf/descriptor.proto">

Visibility0
rules (2.google.api.VisibilityRuleRrules"N
VisibilityRule
selector (	Rselector 
restriction (	Rrestriction:d
enum_visibility.google.protobuf.EnumOptions�ʼ" (2.google.api.VisibilityRuleRenumVisibility:k
value_visibility!.google.protobuf.EnumValueOptions�ʼ" (2.google.api.VisibilityRuleRvalueVisibility:g
field_visibility.google.protobuf.FieldOptions�ʼ" (2.google.api.VisibilityRuleRfieldVisibility:m
message_visibility.google.protobuf.MessageOptions�ʼ" (2.google.api.VisibilityRuleRmessageVisibility:j
method_visibility.google.protobuf.MethodOptions�ʼ" (2.google.api.VisibilityRuleRmethodVisibility:e
api_visibility.google.protobuf.ServiceOptions�ʼ" (2.google.api.VisibilityRuleRapiVisibilityBn
com.google.apiBVisibilityProtoPZ?google.golang.org/genproto/googleapis/api/visibility;visibility��GAPIJ�
 n
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 
	
 

 V
	
 V

 "
	

 "

 0
	
 0

 '
	
 '

 "
	
$ "
	
 
"
 7 See `VisibilityRule`.



 "


 


 +


 .6
	
  #
"
"8 See `VisibilityRule`.



 '


"


",


"/7
	
% (
"
'8 See `VisibilityRule`.



%#


'


',


'/7
	
* -
"
,: See `VisibilityRule`.



*%


,


,.


,19
	
/ 2
"
19 See `VisibilityRule`.



/$


1


1-


108
	
4 7
"
66 See `VisibilityRule`.



4%


6


6*


6-5
�
 O T� `Visibility` defines restrictions for the visibility of service
 elements.  Restrictions are specified using visibility labels
 (e.g., PREVIEW) that are elsewhere linked to users and projects.

 Users and projects can have access to more than one visibility label. The
 effective visibility for multiple labels is the union of each label's
 elements, plus any unrestricted elements.

 If an element and its parents have no restrictions, visibility is
 unconditionally granted.

 Example:

     visibility:
       rules:
       - selector: google.calendar.Calendar.EnhancedSearch
         restriction: PREVIEW
       - selector: google.calendar.Calendar.Delegate
         restriction: INTERNAL

 Here, all methods are publicly visible except for the restricted methods
 EnhancedSearch and Delegate.



 O
�
  S$� A list of visibility rules that apply to individual API elements.

 **NOTE:** All service configuration rules follow "last one wins" order.


  S


  S

  S

  S"#
a
X nU A visibility rule provides visibility configuration for an individual API
 element.



X
�
 \� Selects methods, messages, fields, enums, etc. to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 \

 \	

 \
�
m� A comma-separated list of visibility labels that apply to the `selector`.
 Any of the listed labels can be used to grant the visibility.

 If a rule has multiple labels, removing one of the labels but not all of
 them can break clients.

 Example:

     visibility:
       rules:
       - selector: google.calendar.Calendar.EnhancedSearch
         restriction: INTERNAL, PREVIEW

 Removing INTERNAL from this restriction will break clients that rely on
 this method and only had access to it through INTERNAL.


m

m	

mbproto3
ʏ
*google/rpc/context/attribute_context.protogoogle.rpc.contextgoogle/protobuf/any.protogoogle/protobuf/duration.protogoogle/protobuf/struct.protogoogle/protobuf/timestamp.proto"�
AttributeContextA
origin (2).google.rpc.context.AttributeContext.PeerRoriginA
source (2).google.rpc.context.AttributeContext.PeerRsourceK
destination (2).google.rpc.context.AttributeContext.PeerRdestinationF
request (2,.google.rpc.context.AttributeContext.RequestRrequestI
response (2-.google.rpc.context.AttributeContext.ResponseRresponseI
resource (2-.google.rpc.context.AttributeContext.ResourceRresource:
api (2(.google.rpc.context.AttributeContext.ApiRapi4

extensions (2.google.protobuf.AnyR
extensions�
Peer
ip (	Rip
port (RportM
labels (25.google.rpc.context.AttributeContext.Peer.LabelsEntryRlabels
	principal (	R	principal
region_code (	R
regionCode9
LabelsEntry
key (	Rkey
value (	Rvalue:8s
Api
service (	Rservice
	operation (	R	operation
protocol (	Rprotocol
version (	Rversion�
Auth
	principal (	R	principal
	audiences (	R	audiences
	presenter (	R	presenter/
claims (2.google.protobuf.StructRclaims#
access_levels (	RaccessLevels�
Request
id (	Rid
method (	RmethodS
headers (29.google.rpc.context.AttributeContext.Request.HeadersEntryRheaders
path (	Rpath
host (	Rhost
scheme (	Rscheme
query (	Rquery.
time	 (2.google.protobuf.TimestampRtime
size
 (Rsize
protocol (	Rprotocol
reason (	Rreason=
auth (2).google.rpc.context.AttributeContext.AuthRauth:
HeadersEntry
key (	Rkey
value (	Rvalue:8�
Response
code (Rcode
size (RsizeT
headers (2:.google.rpc.context.AttributeContext.Response.HeadersEntryRheaders.
time (2.google.protobuf.TimestampRtimeB
backend_latency (2.google.protobuf.DurationRbackendLatency:
HeadersEntry
key (	Rkey
value (	Rvalue:8�
Resource
service (	Rservice
name (	Rname
type (	RtypeQ
labels (29.google.rpc.context.AttributeContext.Resource.LabelsEntryRlabels
uid (	Ruid`
annotations (2>.google.rpc.context.AttributeContext.Resource.AnnotationsEntryRannotations!
display_name (	RdisplayName;
create_time (2.google.protobuf.TimestampR
createTime;
update_time	 (2.google.protobuf.TimestampR
updateTime;
delete_time
 (2.google.protobuf.TimestampR
deleteTime
etag (	Retag
location (	Rlocation9
LabelsEntry
key (	Rkey
value (	Rvalue:8>
AnnotationsEntry
key (	Rkey
value (	Rvalue:8B�
com.google.rpc.contextBAttributeContextProtoPZUgoogle.golang.org/genproto/googleapis/rpc/context/attribute_context;attribute_context�J�x
 �
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #
	
 (
	
 &
	
 )

 
	
 

 l
	
 l

 "
	

 "

 6
	
 6

 /
	
 /
�
 . �� This message defines the standard attribute vocabulary for Google APIs.

 An attribute is a piece of metadata that describes an activity on a network
 service. For example, the size of an HTTP request, or the status code of
 an HTTP response.

 Each attribute has a type and a name, which is logically defined as
 a proto message field in `AttributeContext`. The field type becomes the
 attribute type, and the field path becomes the attribute name. For example,
 the attribute `source.ip` maps to field `AttributeContext.source.ip`.

 This message definition is guaranteed not to have any wire breaking change.
 So you can use it directly for passing attributes across different systems.

 NOTE: Different system may generate different subset of attributes. Please
 verify the system specification before relying on an attribute generated
 a system.



 .
�
  3F� This message defines attributes for a node that handles a network request.
 The node can be either a service or an application that sends, forwards,
 or receives the request. Service peers should fill in
 `principal` and `labels` as appropriate.


  3

,
   5 The IP address of the peer.


   5


   5

   5
.
  8 The network port of the peer.


  8	

  8


  8
5
  ;#& The labels associated with the peer.


  ;

  ;

  ;!"
�
  @� The identity of this peer. Similar to `Request.auth.principal`, but
 relative to the peer instead of the request. For example, the
 idenity associated with a load balancer that forwared the request.


  @


  @

  @
�
  E� The CLDR country/region code associated with the above IP address.
 If the IP address is private, the `region_code` should reflect the
 physical location where this peer is running.


  E


  E

  E
�
 K]� This message defines attributes associated with API operations, such as
 a network API request. The terminology is based on the conventions used
 by Google APIs, Istio, and OpenAPI.


 K

�
  O� The API service name. It is a logical identifier for a networked API,
 such as "pubsub.googleapis.com". The naming syntax depends on the
 API management system being used for handling the request.


  O


  O

  O
�
 T� The API operation name. For gRPC requests, it is the fully qualified API
 method name, such as "google.pubsub.v1.Publisher.Publish". For OpenAPI
 requests, it is the `operationId`, such as "getPet".


 T


 T

 T
p
 Xa The API protocol used for sending the request, such as "http", "https",
 "grpc", or "internal".


 X


 X

 X
f
 \W The API version associated with the API operation above, such as "v1" or
 "v1alpha1".


 \


 \

 \
�
 b�� This message defines request authentication attributes. Terminology is
 based on the JSON Web Token (JWT) standard, but the terms also
 correlate to concepts in other standards.


 b

�
  h� The authenticated principal. Reflects the issuer (`iss`) and subject
 (`sub`) claims within a JWT. The issuer and subject should be `/`
 delimited, with `/` percent-encoded within the subject fragment. For
 Google accounts, the principal format is:
 "https://accounts.google.com/{id}"


  h


  h

  h
�
 x"� The intended audience(s) for this authentication information. Reflects
 the audience (`aud`) claim within a JWT. The audience
 value(s) depends on the `issuer`, but typically include one or more of
 the following pieces of information:

 *  The services intended to receive the credential. For example,
    ["https://pubsub.googleapis.com/", "https://storage.googleapis.com/"].
 *  A set of service-based scopes. For example,
    ["https://www.googleapis.com/auth/cloud-platform"].
 *  The client id of an app, such as the Firebase project id for JWTs
    from Firebase Auth.

 Consult the documentation for the credential issuer to determine the
 information provided.


 x

 x

 x

 x !
�
 ~� The authorized presenter of the credential. Reflects the optional
 Authorized Presenter (`azp`) claim within a JWT or the
 OAuth client id. For example, a Google Cloud Platform client id looks
 as follows: "123456789012.apps.googleusercontent.com".


 ~


 ~

 ~
�
 �&� Structured claims presented with the credential. JWTs include
 `{key: value}` pairs for standard and private claims. The following
 is a subset of the standard required and optional claims that would
 typically be presented for a Google-based JWT:

    {'iss': 'accounts.google.com',
     'sub': '113289723416554971153',
     'aud': ['123456789012', 'pubsub.googleapis.com'],
     'azp': '123456789012.apps.googleusercontent.com',
     'email': 'jsmith@example.com',
     'iat': 1353601026,
     'exp': 1353604926}

 SAML assertions are similarly specified, but with an identity provider
 dependent structure.


 �

 �!

 �$%
�
 �&� A list of access level resource names that allow resources to be
 accessed by authenticated requester. It is part of Secure GCP processing
 for the incoming request. An access level string has the format:
 "//{api_service_name}/accessPolicies/{policy_id}/accessLevels/{short_name}"

 Example:
 "//accesscontextmanager.googleapis.com/accessPolicies/MY_POLICY_ID/accessLevels/MY_LEVEL"


 �

 �

 �!

 �$%
�
 ��� This message defines attributes for an HTTP request. If the actual
 request is not an HTTP request, the runtime system should try to map
 the actual request to an equivalent HTTP request.


 �

�
  �� The unique ID for a request, which can be propagated to downstream
 systems. The ID should have low probability of collision
 within a single day for a specific service.


  �


  �

  �
A
 �1 The HTTP request method, such as `GET`, `POST`.


 �


 �

 �
�
 �$� The HTTP request headers. If multiple headers share the same key, they
 must be merged according to the HTTP spec. All header keys must be
 lowercased, because HTTP header keys are case-insensitive.


 �

 �

 �"#
$
 � The HTTP URL path.


 �


 �

 �
7
 �' The HTTP request `Host` header value.


 �


 �

 �
B
 �2 The HTTP URL scheme, such as `http` and `https`.


 �


 �

 �
�
 �� The HTTP URL query in the format of `name1=value1&name2=value2`, as it
 appears in the first line of the HTTP request. No decoding is performed.


 �


 �

 �
f
 �'V The timestamp when the `destination` service receives the last byte of
 the request.


 �

 �"

 �%&
L
 �< The HTTP request size in bytes. If unknown, it must be -1.


 �	

 �


 �
�
 	�� The network protocol used with the request, such as "http/1.1",
 "spdy/3", "h2", "h2c", "webrtc", "tcp", "udp", "quic". See
 https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml#alpn-protocol-ids
 for details.


 	�


 	�

 	�
�
 
�{ A special parameter for request reason. It is used by security systems
 to associate auditing information with a request.


 
�


 
�

 
�
�
 �� The request authentication. May be absent for unauthenticated requests.
 Derived from the HTTP request `Authorization` header or equivalent.


 �

 �	

 �
�
 ��u This message defines attributes for a typical network response. It
 generally models semantics of an HTTP response.


 �

I
  �9 The HTTP response status code, such as `200` and `404`.


  �	

  �


  �
M
 �= The HTTP response size in bytes. If unknown, it must be -1.


 �	

 �


 �
�
 �$� The HTTP response headers. If multiple headers share the same key, they
 must be merged according to HTTP spec. All header keys must be
 lowercased, because HTTP header keys are case-insensitive.


 �

 �

 �"#
d
 �'T The timestamp when the `destination` service sends the last byte of
 the response.


 �

 �"

 �%&
�
 �1� The length of time it takes the backend service to fully respond to a
 request. Measured from when the destination service starts to send the
 request to the backend until when the destination service receives the
 complete response from the backend.


 �

 �,

 �/0
�
 ��� This message defines core attributes for a resource. A resource is an
 addressable (named) entity provided by the destination service. For
 example, a file stored on a network storage service.


 �

�
  �� The name of the service that this resource belongs to, such as
 `pubsub.googleapis.com`. The service may be different from the DNS
 hostname that actually serves the request.


  �


  �

  �
�
 �� The stable identifier (name) of a resource on the `service`. A resource
 can be logically identified as "//{resource.service}/{resource.name}".
 The differences between a resource name and a URI are:

 *   Resource name is a logical identifier, independent of network
     protocol and API version. For example,
     `//pubsub.googleapis.com/projects/123/topics/news-feed`.
 *   URI often includes protocol and version information, so it can
     be used directly by applications. For example,
     `https://pubsub.googleapis.com/v1/projects/123/topics/news-feed`.

 See https://cloud.google.com/apis/design/resource_names for details.


 �


 �

 �
�
 �� The type of the resource. The syntax is platform-specific because
 different platforms define their resources differently.

 For Google APIs, the type format must be "{service}/{kind}".


 �


 �

 �
p
 �#` The labels or tags on the resource, such as AWS resource tags and
 Kubernetes resource labels.


 �

 �

 �!"
�
 �� The unique identifier of the resource. UID is unique in the time
 and space for this resource within the scope of the service. It is
 typically generated by the server on successful creation of a resource
 and must not be changed. UID is used to uniquely identify resources
 with resource name reuses. This should be a UUID4.


 �


 �

 �
�
 �(� Annotations is an unstructured key-value map stored with a resource that
 may be set by external tools to store and retrieve arbitrary metadata.
 They are not queryable and should be preserved when modifying objects.

 More info: https://kubernetes.io/docs/user-guide/annotations


 �

 �#

 �&'
U
 �E Mutable. The display name set by clients. Must be <= 63 characters.


 �


 �

 �
�
 �.� Output only. The timestamp when the resource was created. This may
 be either the time creation was initiated or when it was completed.


 �

 �)

 �,-
�
 �.� Output only. The timestamp when the resource was last updated. Any
 change to the resource made by users must refresh this value.
 Changes to a resource made by the service should refresh this value.


 �

 �)

 �,-
�
 	�/p Output only. The timestamp when the resource was deleted.
 If the resource is not deleted, this must be empty.


 	�

 	�)

 	�,.
�
 
�� Output only. An opaque value that uniquely identifies a version or
 generation of a resource. It can be used to confirm that the client
 and server agree on the ordering of a resource being written.


 
�


 
�

 
�
�
 �� Immutable. The location of the resource. The location encoding is
 specific to the service provider, and new encoding may be introduced
 as the service evolves.

 For Google Cloud products, the encoding is what is used by Google Cloud
 APIs, such as `us-east1`, `aws-us-east-1`, and `azure-eastus2`. The
 semantics of `location` is identical to the
 `cloud.googleapis.com/location` label used by some Google Cloud APIs.


 �


 �

 �
�
  �� The origin of a network activity. In a multi hop network activity,
 the origin represents the sender of the first hop. For the first hop,
 the `source` and the `origin` must have the same content.


  �

  �

  �
�
 �� The source of a network activity, such as starting a TCP connection.
 In a multi hop network activity, the source represents the sender of the
 last hop.


 �

 �

 �
�
 �� The destination of a network activity, such as accepting a TCP connection.
 In a multi hop network activity, the destination represents the receiver of
 the last hop.


 �

 �

 �
F
 �8 Represents a network request, such as an HTTP request.


 �	

 �


 �
H
 �: Represents a network response, such as an HTTP response.


 �


 �

 �
�
 �� Represents a target resource that is involved with a network activity.
 If multiple resources are involved with an activity, this must be the
 primary one.


 �


 �

 �
S
 �E Represents an API operation that is involved to a network activity.


 �

 �	

 �
U
 �.G Supports extensions for advanced use cases, such as logs and metrics.


 �


 �

 �)

 �,-bproto3
�
google/rpc/status.proto
google.rpcgoogle/protobuf/any.proto"f
Status
code (Rcode
message (	Rmessage.
details (2.google.protobuf.AnyRdetailsBa
com.google.rpcBStatusProtoPZ7google.golang.org/genproto/googleapis/rpc/status;status��RPCJ�
 .
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #

 
	
 

 N
	
 N

 "
	

 "

 ,
	
 ,

 '
	
 '

 !
	
$ !
�
 " .� The `Status` type defines a logical error model that is suitable for
 different programming environments, including REST APIs and RPC APIs. It is
 used by [gRPC](https://github.com/grpc). Each `Status` message contains
 three pieces of data: error code, error message, and error details.

 You can find out more about this error model and how to work with it in the
 [API Design Guide](https://cloud.google.com/apis/design/errors).



 "
d
  $W The status code, which should be an enum value of [google.rpc.Code][google.rpc.Code].


  $

  $

  $
�
 )� A developer-facing error message, which should be in English. Any
 user-facing error message should be localized and sent in the
 [google.rpc.Status.details][google.rpc.Status.details] field, or localized by the client.


 )

 )	

 )
y
 -+l A list of messages that carry the error details.  There is a common set of
 message types for APIs to use.


 -


 -

 -&

 -)*bproto3
�n
"google/cloud/audit/audit_log.protogoogle.cloud.auditgoogle/protobuf/any.protogoogle/protobuf/struct.proto*google/rpc/context/attribute_context.protogoogle/rpc/status.proto"�
AuditLog!
service_name (	RserviceName
method_name (	R
methodName#
resource_name (	RresourceNameQ
resource_location (2$.google.cloud.audit.ResourceLocationRresourceLocationO
resource_original_state (2.google.protobuf.StructRresourceOriginalState,
num_response_items (RnumResponseItems*
status (2.google.rpc.StatusRstatusW
authentication_info (2&.google.cloud.audit.AuthenticationInfoRauthenticationInfoT
authorization_info	 (2%.google.cloud.audit.AuthorizationInfoRauthorizationInfoN
request_metadata (2#.google.cloud.audit.RequestMetadataRrequestMetadata1
request (2.google.protobuf.StructRrequest3
response (2.google.protobuf.StructRresponse3
metadata (2.google.protobuf.StructRmetadata;
service_data (2.google.protobuf.AnyBRserviceData"�
AuthenticationInfo'
principal_email (	RprincipalEmail-
authority_selector (	RauthoritySelectorK
third_party_principal (2.google.protobuf.StructRthirdPartyPrincipal7
service_account_key_name (	RserviceAccountKeyNamew
service_account_delegation_info (20.google.cloud.audit.ServiceAccountDelegationInfoRserviceAccountDelegationInfo+
principal_subject (	RprincipalSubject"�
AuthorizationInfo
resource (	Rresource

permission (	R
permission
granted (Rgranted^
resource_attributes (2-.google.rpc.context.AttributeContext.ResourceRresourceAttributes"�
RequestMetadata
	caller_ip (	RcallerIp;
caller_supplied_user_agent (	RcallerSuppliedUserAgent%
caller_network (	RcallerNetwork[
request_attributes (2,.google.rpc.context.AttributeContext.RequestRrequestAttributes`
destination_attributes (2).google.rpc.context.AttributeContext.PeerRdestinationAttributes"n
ResourceLocation+
current_locations (	RcurrentLocations-
original_locations (	RoriginalLocations"�
ServiceAccountDelegationInfo+
principal_subject (	RprincipalSubjectz
first_party_principal (2D.google.cloud.audit.ServiceAccountDelegationInfo.FirstPartyPrincipalH RfirstPartyPrincipalz
third_party_principal (2D.google.cloud.audit.ServiceAccountDelegationInfo.ThirdPartyPrincipalH RthirdPartyPrincipal�
FirstPartyPrincipal'
principal_email (	RprincipalEmailB
service_metadata (2.google.protobuf.StructRserviceMetadata\
ThirdPartyPrincipalE
third_party_claims (2.google.protobuf.StructRthirdPartyClaimsB
	AuthorityBe
com.google.cloud.auditBAuditLogProtoPZ7google.golang.org/genproto/googleapis/cloud/audit;audit�J�Y
 �
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  #
	
 &
	
 4
	
 !

 
	
 

 N
	
 N

 "
	

 "

 .
	
 .

 /
	
 /
O
  iC Common audit log format for Google Cloud Platform API operations.



 
n
  !a The name of the API service performing the operation. For example,
 `"compute.googleapis.com"`.


  !

  !	

  !
�
 )� The name of the service method or operation.
 For API calls, this should be the name of the API method.
 For example,

     "google.cloud.bigquery.v2.TableService.InsertTable"
     "google.logging.v2.ConfigServiceV2.CreateSink"


 )

 )	

 )
�
 1� The resource or collection that is the target of the operation.
 The name is a scheme-less URI, not including the API service name.
 For example:

     "projects/PROJECT_ID/zones/us-central1-a/instances"
     "projects/PROJECT_ID/datasets/DATASET_ID"


 1

 1	

 1
1
 4*$ The resource location information.


 4

 4$

 4')
�
 =6� The resource's original state before mutation. Present only for
 operations which have successfully modified the targeted resource(s).
 In general, this field should contain all changed fields, except those
 that are already been included in `request`, `response`, `metadata` or
 `service_data` fields.
 When the JSON object represented here has a proto equivalent,
 the proto name will be indicated in the `@type` property.


 =

 =0

 =35
\
 A O The number of items returned from a List or Query API method,
 if applicable.


 A

 A

 A
3
 D& The status of the overall operation.


 D

 D

 D
*
 G- Authentication information.


 G

 G(

 G+,
�
 L4� Authorization information. If there are multiple
 resources or permissions involved, then there is
 one AuthorizationInfo element for each {resource, permission} tuple.


 L


 L

 L/

 L23
,
 	O' Metadata about the operation.


 	O

 	O"

 	O%&
�
 
W&� The operation request. This may not include all request parameters,
 such as those that are too large, privacy-sensitive, or duplicated
 elsewhere in the log record.
 It should never include user-generated data, such as file contents.
 When the JSON object represented here has a proto equivalent, the proto
 name will be indicated in the `@type` property.


 
W

 
W 

 
W#%
�
 _'� The operation response. This may not include all response elements,
 such as those that are too large, privacy-sensitive, or duplicated
 elsewhere in the log record.
 It should never include user-generated data, such as file contents.
 When the JSON object represented here has a proto equivalent, the proto
 name will be indicated in the `@type` property.


 _

 _!

 _$&
�
 c'| Other service-specific data about the request, response, and other
 information associated with the current audited event.


 c

 c!

 c$&
�
 h<� Deprecated. Use the `metadata` field instead.
 Other service-specific data about the request, response, and other
 activities.


 h

 h"

 h%'

 h(;

 h):
<
l �/ Authentication information for the operation.



l
�
 s� The email address of the authenticated user (or service account on behalf
 of third party principal) making the request. For third party identity
 callers, the `principal_subject` field is populated instead of this field.
 For privacy reasons, the principal email address is sometimes redacted.
 For more information, see
 https://cloud.google.com/logging/docs/audit#user-id.


 s

 s	

 s
�
w � The authority selector specified by the requestor, if any.
 It is not guaranteed that the principal was allowed to use this authority.


w

w	

w
�
}3� The third party identification (if any) of the authenticated user making
 the request.
 When the JSON object represented here has a proto equivalent, the proto
 name will be indicated in the `@type` property.


}

}.

}12
�
�&� The name of the service account key used to create or exchange
 credentials for authenticating the service account making the request.
 This is a scheme-less URI full resource name. For example:

 "//iam.googleapis.com/projects/{PROJECT_ID}/serviceAccounts/{ACCOUNT}/keys/{key}"


�

�	!

�$%
�
�L� Identity delegation history of an authenticated service account that makes
 the request. It contains information on the real authorities that try to
 access GCP resources by delegating on a service account. When multiple
 authorities present, they are guaranteed to be sorted based on the original
 ordering of the identity delegation events.


�


�'

�(G

�JK
|
�n String representation of identity of requesting party.
 Populated for both first and third party identities.


�

�	

�
<
� �. Authorization information for the operation.


�
�
 �� The resource being accessed, as a REST-style or cloud resource string.
 For example:

     bigquery.googleapis.com/projects/PROJECTID/datasets/DATASETID
 or
     projects/PROJECTID/datasets/DATASETID


 �

 �	

 �
,
� The required IAM permission.


�

�	

�
Z
�L Whether or not authorization for `resource` and `permission`
 was granted.


�

�

�
�
�G� Resource attributes used in IAM condition evaluation. This field contains
 resource attributes like resource type and resource name.

 To get the whole view of the attributes used in IAM
 condition evaluation, the user must also look into
 `AuditLog.request_metadata.request_attributes`.


�.

�/B

�EF
+
� � Metadata about the request.


�
�
 �� The IP address of the caller.
 For caller from internet, this will be public IPv4 or IPv6 address.
 For caller from a Compute Engine VM with external IP address, this
 will be the VM's external IP address. For caller from a Compute
 Engine VM without external IP address, if the VM is in the same
 organization (or project) as the accessed resource, `caller_ip` will
 be the VM's internal IPv4 address, otherwise the `caller_ip` will be
 redacted to "gce-internal-ip".
 See https://cloud.google.com/compute/docs/vpc/ for more information.


 �

 �	

 �
�
�(� The user agent of the caller.
 This information is not authenticated and should be treated accordingly.
 For example:

 +   `google-api-python-client/1.4.0`:
     The request was made by the Google API client for Python.
 +   `Cloud SDK Command Line Tool apitools-client/1.0 gcloud/0.9.62`:
     The request was made by the Google Cloud SDK CLI (gcloud).
 +   `AppEngine-Google; (+http://code.google.com/appengine; appid:
 s~my-project`:
     The request was made from the `my-project` App Engine app.


�

�	#

�&'
�
�� The network of the caller.
 Set only if the network host project is part of the same GCP organization
 (or project) as the accessed resource.
 See https://cloud.google.com/compute/docs/vpc/ for more information.
 This is a scheme-less URI full resource name. For example:

     "//compute.googleapis.com/projects/PROJECT_ID/global/networks/NETWORK_ID"


�

�	

�
�
�E� Request attributes used in IAM condition evaluation. This field contains
 request attributes like request time and access levels associated with
 the request.


 To get the whole view of the attributes used in IAM
 condition evaluation, the user must also look into
 `AuditLog.authentication_info.resource_attributes`.


�-

�.@

�CD
�
�F� The destination of a network activity, such as accepting a TCP connection.
 In a multi hop network activity, the destination represents the receiver of
 the last hop. Only two fields are used in this message, Peer.port and
 Peer.ip. These fields are optionally populated by those services utilizing
 the IAM condition feature.


�*

�+A

�DE
6
� �( Location information about a resource.


�
�
 �(� The locations of a resource after the execution of the operation.
 Requests to create or delete a location based resource must populate
 the 'current_locations' field and not the 'original_locations' field.
 For example:

     "europe-west1-a"
     "us-east1"
     "nam3"


 �


 �

 �#

 �&'
�
�)� The locations of a resource prior to the execution of the operation.
 Requests that mutate the resource's location must populate both the
 'original_locations' as well as the 'current_locations' fields.
 For example:

     "europe-west1-a"
     "us-east1"
     "nam3"


�


�

�$

�'(
P
� �B Identity delegation history of an authenticated service account.


�$
1
 ��! First party identity principal.


 �

8
  �( The email address of a Google account.


  �


  �

  �
K
 �0; Metadata about the service that uses the service account.


 �

 �+

 �./
1
��! Third party identity principal.


�

6
 �2& Metadata about third party identity.


 �

 �-

 �01
�
 �� A string representing the principal_subject associated with the identity.
 For most identities, the format will be
 `principal://iam.googleapis.com/{identity pool name}/subject/{subject)`
 except for some GKE identities (GKE_WORKLOAD, FREEFORM, GKE_HUB_WORKLOAD)
 that are still in the legacy format `serviceAccount:{identity pool
 name}[{subject}]`


 �

 �	

 �
s
 ��c Entity that creates credentials for service account and assumes its
 identity for authentication.


 �
D
�26 First party (Google) identity as the real authority.


�

�-

�01
;
�2- Third party identity as the real authority.


�

�-

�01bproto3
�5
&google/cloud/extended_operations.protogoogle.cloud google/protobuf/descriptor.proto*b
OperationResponseMapping
	UNDEFINED 
NAME

STATUS

ERROR_CODE
ERROR_MESSAGE:o
operation_field.google.protobuf.FieldOptions� (2&.google.cloud.OperationResponseMappingRoperationField:V
operation_request_field.google.protobuf.FieldOptions� (	RoperationRequestField:X
operation_response_field.google.protobuf.FieldOptions� (	RoperationResponseField:L
operation_service.google.protobuf.MethodOptions�	 (	RoperationService:Y
operation_polling_method.google.protobuf.MethodOptions�	 (RoperationPollingMethodBy
com.google.cloudBExtendedOperationsProtoPZCgoogle.golang.org/genproto/googleapis/cloud/extendedops;extendedops�GAPIJ�.
 �
�
 � This file contains custom annotations that are used by GAPIC generators to
 handle Long Running Operation methods (LRO) that are NOT compliant with
 https://google.aip.dev/151. These annotations are public for technical
 reasons only. Please DO NOT USE them in your protos.
2� Copyright 2021 Google LLC.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  *

 Z
	
 Z

 "
	

 "

 8
	
 8

 )
	
 )

 "
	
$ "
�
< W� FieldOptions to match corresponding fields in the initial request,
 polling request and operation response messages.

 Example:

 In an API-specific operation message:

     message MyOperation {
       string http_error_message = 1 [(operation_field) = ERROR_MESSAGE];
       int32 http_error_status_code = 2 [(operation_field) = ERROR_CODE];
       string id = 3 [(operation_field) = NAME];
       Status status = 4 [(operation_field) = STATUS];
     }

 In a polling request message (the one which is used to poll for an LRO
 status):

     message MyPollingRequest {
       string operation = 1 [(operation_response_field) = "id"];
       string project = 2;
       string region = 3;
     }

 In an initial request message (the one which starts an LRO):

    message MyInitialRequest {
      string my_project = 2 [(operation_request_field) = "project"];
      string my_region = 3 [(operation_request_field) = "region"];
    }


�
 @2� A field annotation that maps fields in an API-specific Operation object to
 their standard counterparts in google.longrunning.Operation. See
 OperationResponseMapping enum definition.



 <#


 @


 @*


 @-1
�
K(� A field annotation that maps fields in the initial request message
 (the one which started the LRO) to their counterparts in the polling
 request message. For non-standard LRO, the polling response may be missing
 some of the information needed to make a subsequent polling request. The
 missing information (for example, project or region ID) is contained in the
 fields of the initial request message that this annotation must be applied
 to. The string value of the annotation corresponds to the name of the
 counterpart field in the polling request message that the annotated field's
 value will be copied to.



<#


K


K	 


K#'
�
V)� A field annotation that maps fields in the polling request message to their
 counterparts in the initial and/or polling response message. The initial
 and the polling methods return an API-specific Operation object. Some of
 the fields from that response object must be reused in the subsequent
 request (like operation name/ID) to fully identify the polled operation.
 This annotation must be applied to the fields in the polling request
 message, the string value of the annotation must correspond to the name of
 the counterpart field in the Operation response object whose value will be
 copied to the annotated field.



<#


V


V	!


V$(
�
m x� MethodOptions to identify the actual service and method used for operation
 status polling.

 Example:

 In a method, which starts an LRO:

     service MyService {
       rpc Foo(MyInitialRequest) returns (MyOperation) {
         option (operation_service) = "MyPollingService";
       }
     }

 In a polling method:

     service MyPollingService {
       rpc Get(MyPollingRequest) returns (MyOperation) {
         option (operation_polling_method) = true;
       }
     }

�
s"� A method annotation that maps an LRO method (the one which starts an LRO)
 to the service, which will be used to poll for the operation status. The
 annotation must be applied to the method which starts an LRO, the string
 value of the annotation must correspond to the name of the service used to
 poll for the operation status.



m$


s


s	


s!
�
w'� A method annotation that marks methods that can be used for polling
 operation status (e.g. the MyPollingService.Get(MyPollingRequest) method).



m$


w


w


w"&
�
 ~ �� An enum to be used to mark the essential (for polling) fields in an
 API-specific Operation object. A custom Operation object may contain many
 different fields, but only few of them are essential to conduct a successful
 polling process.



 ~

  � Do not use.


  �

  �
�
 �| A field in an API-specific (custom) Operation object which carries the same
 meaning as google.longrunning.Operation.name.


 �

 �	

�
 �� A field in an API-specific (custom) Operation object which carries the same
 meaning as google.longrunning.Operation.done. If the annotated field is of
 an enum type, `annotated_field_name == EnumType.DONE` semantics should be
 equivalent to `Operation.done == true`. If the annotated field is of type
 boolean, then it should follow the same semantics as Operation.done.
 Otherwise, a non-empty value should be treated as `Operation.done == true`.


 �

 �
�
 �� A field in an API-specific (custom) Operation object which carries the same
 meaning as google.longrunning.Operation.error.code.


 �

 �
�
 �� A field in an API-specific (custom) Operation object which carries the same
 meaning as google.longrunning.Operation.error.message.


 �

 �bproto3
�
google/type/latlng.protogoogle.type"B
LatLng
latitude (Rlatitude
	longitude (R	longitudeBc
com.google.typeBLatLngProtoPZ8google.golang.org/genproto/googleapis/type/latlng;latlng��GTPJ�

 $
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 O
	
 O

 "
	

 "

 ,
	
 ,

 (
	
 (

 !
	
$ !
�
  $� An object that represents a latitude/longitude pair. This is expressed as a
 pair of doubles to represent degrees latitude and degrees longitude. Unless
 specified otherwise, this must conform to the
 <a href="http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf">WGS84
 standard</a>. Values must be within normalized ranges.



 
O
   B The latitude in degrees. It must be in the range [-90.0, +90.0].


   

   	

   
R
 #E The longitude in degrees. It must be in the range [-180.0, +180.0].


 #

 #	

 #bproto3
�
google/geo/type/viewport.protogoogle.geo.typegoogle/type/latlng.proto"Z
Viewport%
low (2.google.type.LatLngRlow'
high (2.google.type.LatLngRhighBo
com.google.geo.typeBViewportProtoPZ@google.golang.org/genproto/googleapis/geo/type/viewport;viewport�GGTPJ�
 D
�
 2� Copyright 2019 Google LLC.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.



 
	
  "

 W
	
 W

 "
	

 "

 .
	
 .

 ,
	
 ,

 "
	
$ "
�	
 > D�	 A latitude-longitude viewport, represented as two diagonally opposite `low`
 and `high` points. A viewport is considered a closed region, i.e. it includes
 its boundary. The latitude bounds must range between -90 to 90 degrees
 inclusive, and the longitude bounds must range between -180 to 180 degrees
 inclusive. Various cases include:

  - If `low` = `high`, the viewport consists of that single point.

  - If `low.longitude` > `high.longitude`, the longitude range is inverted
    (the viewport crosses the 180 degree longitude line).

  - If `low.longitude` = -180 degrees and `high.longitude` = 180 degrees,
    the viewport includes all longitudes.

  - If `low.longitude` = 180 degrees and `high.longitude` = -180 degrees,
    the longitude range is empty.

  - If `low.latitude` > `high.latitude`, the latitude range is empty.

 Both `low` and `high` must be populated, and the represented box cannot be
 empty (as specified by the definitions above). An empty viewport will result
 in an error.

 For example, this viewport fully encloses New York City:

 {
     "low": {
         "latitude": 40.477398,
         "longitude": -74.259087
     },
     "high": {
         "latitude": 40.91618,
         "longitude": -73.70018
     }
 }



 >
7
  @* Required. The low point of the viewport.


  @

  @

  @
8
 C+ Required. The high point of the viewport.


 C

 C

 Cbproto3
�"
&google/logging/type/http_request.protogoogle.logging.typegoogle/protobuf/duration.proto"�
HttpRequest%
request_method (	RrequestMethod
request_url (	R
requestUrl!
request_size (RrequestSize
status (Rstatus#
response_size (RresponseSize

user_agent (	R	userAgent
	remote_ip (	RremoteIp
	server_ip (	RserverIp
referer (	Rreferer3
latency (2.google.protobuf.DurationRlatency!
cache_lookup (RcacheLookup
	cache_hit	 (RcacheHitJ
"cache_validated_with_origin_server
 (RcacheValidatedWithOriginServer(
cache_fill_bytes (RcacheFillBytes
protocol (	RprotocolB�
com.google.logging.typeBHttpRequestProtoPZ8google.golang.org/genproto/googleapis/logging/type;ltype�Google.Cloud.Logging.Type�Google\Cloud\Logging\Type�Google::Cloud::Logging::TypeJ�
 ^
�
 2� Copyright 2022 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  (

 6
	
% 6

 O
	
 O

 "
	

 "

 1
	
 1

 0
	
 0

 6
	
) 6

 5
	
- 5
�
  ^� A common proto for logging HTTP requests. Only contains semantics
 defined by the HTTP specification. Product-specific logging
 information MUST be defined in a separate message.



 
R
  !E The request method. Examples: `"GET"`, `"HEAD"`, `"PUT"`, `"POST"`.


  !

  !	

  !
�
 &� The scheme (http, https), the host name, the path and the query
 portion of the URL that was requested.
 Example: `"http://example.com/some/info?color=red"`.


 &

 &	

 &
r
 *e The size of the HTTP request message in bytes, including the request
 headers and the request body.


 *

 *

 *
X
 .K The response code indicating the status of response.
 Examples: 200, 404.


 .

 .

 .
�
 2� The size of the HTTP response message sent back to the client, in bytes,
 including the response headers and the response body.


 2

 2

 2
�
 7 The user agent sent by the client. Example:
 `"Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; Q312461; .NET
 CLR 1.0.3705)"`.


 7

 7	

 7
�
 <� The IP address (IPv4 or IPv6) of the client that issued the HTTP
 request. This field can include port information. Examples:
 `"192.168.1.1"`, `"10.0.0.1:80"`, `"FE80::0202:B3FF:FE1E:8329"`.


 <

 <	

 <
�
 A� The IP address (IPv4 or IPv6) of the origin server that the request was
 sent to. This field can include port information. Examples:
 `"192.168.1.1"`, `"10.0.0.1:80"`, `"FE80::0202:B3FF:FE1E:8329"`.


 A

 A	

 A
�
 F� The referer URL of the request, as defined in
 [HTTP/1.1 Header Field
 Definitions](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html).


 F

 F	

 F
�
 	J(t The request processing latency on the server, from the time the request was
 received until the response was sent.


 	J

 	J"

 	J%'
;
 
M. Whether or not a cache lookup was attempted.


 
M

 
M

 
M
\
 QO Whether or not an entity was served from cache
 (with or without validation).


 Q

 Q

 Q
�
 V/� Whether or not the response was validated with the origin server before
 being served from cache. This field is only meaningful if `cache_hit` is
 True.


 V

 V)

 V,.
p
 Zc The number of HTTP response bytes inserted into cache. Set only when a
 cache fill was attempted.


 Z

 Z

 Z
Y
 ]L Protocol used for the request. Examples: "HTTP/1.1", "HTTP/2", "websocket"


 ]

 ]	

 ]bproto3
�
&google/logging/type/log_severity.protogoogle.logging.type*�
LogSeverity
DEFAULT 	
DEBUGd	
INFO�
NOTICE�
WARNING�

ERROR�
CRITICAL�

ALERT�
	EMERGENCY�B�
com.google.logging.typeBLogSeverityProtoPZ8google.golang.org/genproto/googleapis/logging/type;ltype�GLOG�Google.Cloud.Logging.Type�Google\Cloud\Logging\Type�Google::Cloud::Logging::TypeJ�
 F
�
 2� Copyright 2022 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 6
	
% 6

 O
	
 O

 "
	

 "

 1
	
 1

 0
	
 0

 "
	
$ "

 6
	
) 6

 5
	
- 5
�
 * F� The severity of the event described in a log entry, expressed as one of the
 standard severity levels listed below.  For your reference, the levels are
 assigned the listed numeric values. The effect of using numeric values other
 than those listed is undefined.

 You can filter for log entries by severity.  For example, the following
 filter expression will match log entries with severities `INFO`, `NOTICE`,
 and `WARNING`:

     severity > DEBUG AND severity <= WARNING

 If you are writing log entries, you should map other severity encodings to
 one of these standard levels. For example, you might map all of Java's FINE,
 FINER, and FINEST levels to `LogSeverity.DEBUG`. You can preserve the
 original severity level in the log entry payload if you wish.



 *
@
  ,3 (0) The log entry has no assigned severity level.


  ,	

  ,
0
 /# (100) Debug or trace information.


 /

 /

P
 2C (200) Routine information, such as ongoing status or performance.


 2

 2	
l
 6_ (300) Normal but significant events, such as start up, shut down, or
 a configuration change.


 6

 6
9
 9, (400) Warning events might cause problems.


 9	

 9
?
 <2 (500) Error events are likely to cause problems.


 <

 <

K
 ?> (600) Critical events cause more severe problems or outages.


 ?


 ?
>
 B1 (700) A person must take an action immediately.


 B

 B

6
 E) (800) One or more systems are unusable.


 E

 Ebproto3
�
google/protobuf/empty.protogoogle.protobuf"
EmptyB}
com.google.protobufB
EmptyProtoPZ.google.golang.org/protobuf/types/known/emptypb��GPB�Google.Protobuf.WellKnownTypesJ�
 2
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# E
	
# E

$ ,
	
$ ,

% +
	
% +

& "
	

& "

' !
	
$' !

( 
	
( 
�
 2 � A generic empty message that you can re-use to avoid defining duplicated
 empty messages in your APIs. A typical example is to use it as the request
 or the response type of an API method. For instance:

     service Foo {
       rpc Bar(google.protobuf.Empty) returns (google.protobuf.Empty);
     }




 2bproto3
�\
#google/longrunning/operations.protogoogle.longrunninggoogle/api/annotations.protogoogle/api/client.protogoogle/protobuf/any.protogoogle/protobuf/duration.protogoogle/protobuf/empty.protogoogle/rpc/status.proto google/protobuf/descriptor.proto"�
	Operation
name (	Rname0
metadata (2.google.protobuf.AnyRmetadata
done (Rdone*
error (2.google.rpc.StatusH Rerror2
response (2.google.protobuf.AnyH RresponseB
result")
GetOperationRequest
name (	Rname"
ListOperationsRequest
name (	Rname
filter (	Rfilter
	page_size (RpageSize

page_token (	R	pageToken"
ListOperationsResponse=

operations (2.google.longrunning.OperationR
operations&
next_page_token (	RnextPageToken",
CancelOperationRequest
name (	Rname",
DeleteOperationRequest
name (	Rname"_
WaitOperationRequest
name (	Rname3
timeout (2.google.protobuf.DurationRtimeout"Y
OperationInfo#
response_type (	RresponseType#
metadata_type (	RmetadataType2�

Operations�
ListOperations).google.longrunning.ListOperationsRequest*.google.longrunning.ListOperationsResponse"+���/v1/{name=operations}�Aname,filter
GetOperation'.google.longrunning.GetOperationRequest.google.longrunning.Operation"'���/v1/{name=operations/**}�Aname~
DeleteOperation*.google.longrunning.DeleteOperationRequest.google.protobuf.Empty"'���*/v1/{name=operations/**}�Aname�
CancelOperation*.google.longrunning.CancelOperationRequest.google.protobuf.Empty"1���$"/v1/{name=operations/**}:cancel:*�AnameZ
WaitOperation(.google.longrunning.WaitOperationRequest.google.longrunning.Operation" �Alongrunning.googleapis.com:i
operation_info.google.protobuf.MethodOptions� (2!.google.longrunning.OperationInfoRoperationInfoB�
com.google.longrunningBOperationsProtoPZ=google.golang.org/genproto/googleapis/longrunning;longrunning��Google.LongRunning�Google\LongRunningJ�L
 �
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  &
	
 !
	
 #
	
 (
	
 %
	
 !
	
 *

 
	
 

 /
	
% /

 T
	
 T

 "
	

 "

 0
	
 0

 /
	
 /

  -
	
)  -
	
" *
�
 )9� Additional information regarding long-running operations.
 In particular, this specifies the types that are returned from
 long-running operations.

 Required for methods that return `google.longrunning.Operation`; invalid
 otherwise.



 "$


 )"


 )#1


 )48
�
 5 {� Manages long-running operations with an API service.

 When an API method normally takes long time to complete, it can be designed
 to return [Operation][google.longrunning.Operation] to the client, and the client can use this
 interface to receive the real response asynchronously by polling the
 operation resource, or pass the operation resource to another API (such as
 Google Cloud Pub/Sub API) to receive the response.  Any API service that
 returns long-running operations should implement the `Operations` interface
 so developers can have a consistent client experience.



 5


 6B

 �6B
�
  BG� Lists operations that match the specified filter in the request. If the
 server doesn't support this method, it returns `UNIMPLEMENTED`.

 NOTE: the `name` binding allows API services to override the binding
 to use different resource name schemes, such as `users/*/operations`. To
 override the binding, API services can add a binding such as
 `"/v1/{name=users/*}/operations"` to their service configuration.
 For backwards compatibility, the default name includes the operations
 collection id, however overriding users must ensure the name binding
 is the parent resource, without the operations collection id.


  B

  B*

  B5K

  CE

	  �ʼ"CE

  F9

  � F9
�
 LQ� Gets the latest state of a long-running operation.  Clients can use this
 method to poll the operation result at intervals as recommended by the API
 service.


 L

 L&

 L1:

 MO

	 �ʼ"MO

 P2

 � P2
�
 W\� Deletes a long-running operation. This method indicates that the client is
 no longer interested in the operation result. It does not cancel the
 operation. If the server doesn't support this method, it returns
 `google.rpc.Code.UNIMPLEMENTED`.


 W

 W,

 W7L

 XZ

	 �ʼ"XZ

 [2

 � [2
�
 hn� Starts asynchronous cancellation on a long-running operation.  The server
 makes a best effort to cancel the operation, but success is not
 guaranteed.  If the server doesn't support this method, it returns
 `google.rpc.Code.UNIMPLEMENTED`.  Clients can use
 [Operations.GetOperation][google.longrunning.Operations.GetOperation] or
 other methods to check whether the cancellation succeeded or whether the
 operation completed despite cancellation. On successful cancellation,
 the operation is not deleted; instead, it becomes an operation with
 an [Operation.error][google.longrunning.Operation.error] value with a [google.rpc.Status.code][google.rpc.Status.code] of 1,
 corresponding to `Code.CANCELLED`.


 h

 h,

 h7L

 il

	 �ʼ"il

 m2

 � m2
�
 yz� Waits until the specified long-running operation is done or reaches at most
 a specified timeout, returning the latest state.  If the operation is
 already done, the latest state is immediately returned.  If the timeout
 specified is greater than the default HTTP/RPC timeout, the HTTP/RPC
 timeout is used.  If the server does not support this method, it returns
 `google.rpc.Code.UNIMPLEMENTED`.
 Note that this method is on a best-effort basis.  It may return the latest
 state before the specified timeout (including immediately), meaning even an
 immediate response is no guarantee that the operation is done.


 y

 y(

 y3<
k
  �^ This resource represents a long-running operation that is the result of a
 network API call.



 
�
  �� The server-assigned name, which is only unique within the same service that
 originally returns it. If you use the default HTTP mapping, the
 `name` should be a resource name ending with `operations/{unique_id}`.


  �

  �	

  �
�
 �#� Service-specific metadata associated with the operation.  It typically
 contains progress information and common metadata such as create time.
 Some services might not provide such metadata.  Any method that returns a
 long-running operation should document the metadata type, if any.


 �

 �

 �!"
�
 �� If the value is `false`, it means the operation is still in progress.
 If `true`, the operation is completed, and either `error` or `response` is
 available.


 �

 �

 �
�
  ��� The operation result, which can be either an `error` or a valid `response`.
 If `done` == `false`, neither `error` nor `response` is set.
 If `done` == `true`, exactly one of `error` or `response` is set.


  �
U
 � G The error result of the operation in case of failure or cancellation.


 �

 �

 �
�
 �%� The normal response of the operation in case of success.  If the original
 method returns no data on success, such as `Delete`, the response is
 `google.protobuf.Empty`.  If the original method is standard
 `Get`/`Create`/`Update`, the response should be the resource.  For other
 methods, the response should have the type `XxxResponse`, where `Xxx`
 is the original method name.  For example, if the original method name
 is `TakeSnapshot()`, the inferred response type is
 `TakeSnapshotResponse`.


 �

 � 

 �#$
n
� �` The request message for [Operations.GetOperation][google.longrunning.Operations.GetOperation].


�
3
 �% The name of the operation resource.


 �

 �	

 �
r
� �d The request message for [Operations.ListOperations][google.longrunning.Operations.ListOperations].


�
<
 �. The name of the operation's parent resource.


 �

 �	

 �
)
� The standard list filter.


�

�	

�
,
� The standard list page size.


�

�

�
-
� The standard list page token.


�

�	

�
s
� �e The response message for [Operations.ListOperations][google.longrunning.Operations.ListOperations].


�
V
 �$H A list of operations that matches the specified filter in the request.


 �


 �

 �

 �"#
2
�$ The standard List next-page token.


�

�	

�
t
� �f The request message for [Operations.CancelOperation][google.longrunning.Operations.CancelOperation].


�
C
 �5 The name of the operation resource to be cancelled.


 �

 �	

 �
t
� �f The request message for [Operations.DeleteOperation][google.longrunning.Operations.DeleteOperation].


�
A
 �3 The name of the operation resource to be deleted.


 �

 �	

 �
p
� �b The request message for [Operations.WaitOperation][google.longrunning.Operations.WaitOperation].


�
>
 �0 The name of the operation resource to wait on.


 �

 �	

 �
�
�'� The maximum duration to wait before timing out. If left blank, the wait
 will be at most the time permitted by the underlying HTTP/RPC protocol.
 If RPC context deadline is also specified, the shorter one will be used.


�

�"

�%&
�
� �� A message representing the message types used by a long-running operation.

 Example:

   rpc LongRunningRecognize(LongRunningRecognizeRequest)
       returns (google.longrunning.Operation) {
     option (google.longrunning.operation_info) = {
       response_type: "LongRunningRecognizeResponse"
       metadata_type: "LongRunningRecognizeMetadata"
     };
   }


�
�
 �� Required. The message name of the primary return type for this
 long-running operation.
 This type will be used to deserialize the LRO's response.

 If the response is in a different package from the rpc, a fully-qualified
 message name must be used (e.g. `google.protobuf.Struct`).

 Note: Altering this value constitutes a breaking change.


 �

 �	

 �
�
�� Required. The message name of the metadata type for this long-running
 operation.

 If the response is in a different package from the rpc, a fully-qualified
 message name must be used (e.g. `google.protobuf.Struct`).

 Note: Altering this value constitutes a breaking change.


�

�	

�bproto3
�K
%google/protobuf/compiler/plugin.protogoogle.protobuf.compiler google/protobuf/descriptor.proto"c
Version
major (Rmajor
minor (Rminor
patch (Rpatch
suffix (	Rsuffix"�
CodeGeneratorRequest(
file_to_generate (	RfileToGenerate
	parameter (	R	parameterC

proto_file (2$.google.protobuf.FileDescriptorProtoR	protoFileL
compiler_version (2!.google.protobuf.compiler.VersionRcompilerVersion"�
CodeGeneratorResponse
error (	Rerror-
supported_features (RsupportedFeaturesH
file (24.google.protobuf.compiler.CodeGeneratorResponse.FileRfile�
File
name (	Rname'
insertion_point (	RinsertionPoint
content (	RcontentR
generated_code_info (2".google.protobuf.GeneratedCodeInfoRgeneratedCodeInfo"8
Feature
FEATURE_NONE 
FEATURE_PROTO3_OPTIONALBW
com.google.protobuf.compilerBPluginProtosZ)google.golang.org/protobuf/types/pluginpbJ�C
. �
�
. 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)

 WARNING:  The plugin interface is currently EXPERIMENTAL and is subject to
   change.

 protoc (aka the Protocol Compiler) can be extended via plugins.  A plugin is
 just a program that reads a CodeGeneratorRequest from stdin and writes a
 CodeGeneratorResponse to stdout.

 Plugins written using C++ can use google/protobuf/compiler/plugin.h instead
 of dealing with the raw protocol defined here.

 A plugin executable needs only to be placed somewhere in the path.  The
 plugin should be named "protoc-gen-$NAME", and will then be used when the
 flag "--${NAME}_out" is passed to protoc.


0 !

1 5
	
1 5

2 -
	
2 -

4 @
	
4 @
	
 6 *
6
 9 @* The version number of protocol compiler.



 9

  :

  :


  :

  :

  :

 ;

 ;


 ;

 ;

 ;

 <

 <


 <

 <

 <
�
 ?s A suffix for alpha, beta or rc release, e.g., "alpha-1", "rc2". It should
 be empty for mainline stable releases.


 ?


 ?

 ?

 ?
O
C _C An encoded CodeGeneratorRequest is written to the plugin's stdin.



C
�
 G'� The .proto files that were explicitly listed on the command-line.  The
 code generator should generate code only for these files.  Each file's
 descriptor will be included in proto_file, below.


 G


 G

 G"

 G%&
B
J 5 The generator parameter passed on the command-line.


J


J

J

J
�
Z/� FileDescriptorProtos for all files in files_to_generate and everything
 they import.  The files will appear in topological order, so each file
 appears before any file that imports it.

 protoc guarantees that all proto_files will be written after
 the fields above, even though this is not technically guaranteed by the
 protobuf wire format.  This theoretically could allow a plugin to stream
 in the FileDescriptorProtos and handle them one by one rather than read
 the entire set into memory at once.  However, as of this writing, this
 is not similarly optimized on protoc's end -- it will store all fields in
 memory at once before sending them to the plugin.

 Type names of fields and extensions in the FileDescriptorProto are always
 fully qualified.


Z


Z

Z)

Z,.
7
](* The version number of protocol compiler.


]


]

]#

]&'
L
b �? The plugin writes an encoded CodeGeneratorResponse to stdout.



b
�
 k� Error message.  If non-empty, code generation failed.  The plugin process
 should exit with status code zero even if it reports an error in this way.

 This should be used to indicate errors in .proto files which prevent the
 code generator from generating correct code.  Errors which indicate a
 problem in protoc itself -- such as the input CodeGeneratorRequest being
 unparseable -- should be reported by writing a message to stderr and
 exiting with a non-zero status code.


 k


 k

 k

 k
�
o)| A bitmask of supported features that the code generator supports.
 This is a bitwise "or" of values from the Feature enum.


o


o

o$

o'(
+
 ru Sync with code_generator.h.


 r

  s

  s

  s

 t 

 t

 t
4
 x�% Represents a single generated file.


 x

�
  �� The file name, relative to the output directory.  The name must not
 contain "." or ".." components and must be relative, not be absolute (so,
 the file cannot lie outside the output directory).  "/" must be used as
 the path separator, not "\".

 If the name is omitted, the content will be appended to the previous
 file.  This allows the generator to break large files into small chunks,
 and allows the generated text to be streamed back to protoc so that large
 files need not reside completely in memory at one time.  Note that as of
 this writing protoc does not optimize for this -- it will read the entire
 CodeGeneratorResponse before writing files to disk.


  �

  �

  �

  �
�
 �(� If non-empty, indicates that the named file should already exist, and the
 content here is to be inserted into that file at a defined insertion
 point.  This feature allows a code generator to extend the output
 produced by another code generator.  The original generator may provide
 insertion points by placing special annotations in the file that look
 like:
   @@protoc_insertion_point(NAME)
 The annotation can have arbitrary text before and after it on the line,
 which allows it to be placed in a comment.  NAME should be replaced with
 an identifier naming the point -- this is what other generators will use
 as the insertion_point.  Code inserted at this point will be placed
 immediately above the line containing the insertion point (thus multiple
 insertions to the same point will come out in the order they were added).
 The double-@ is intended to make it unlikely that the generated code
 could contain things that look like insertion points by accident.

 For example, the C++ code generator places the following line in the
 .pb.h files that it generates:
   // @@protoc_insertion_point(namespace_scope)
 This line appears within the scope of the file's package namespace, but
 outside of any particular class.  Another plugin can then specify the
 insertion_point "namespace_scope" to generate additional classes or
 other declarations that should be placed in this scope.

 Note that if the line containing the insertion point begins with
 whitespace, the same whitespace will be added to every line of the
 inserted text.  This is useful for languages like Python, where
 indentation matters.  In these languages, the insertion point comment
 should be indented the same amount as any inserted code will need to be
 in order to work correctly in that context.

 The code generator that generates the initial file and the one which
 inserts into it must both run as part of a single invocation of protoc.
 Code generators are executed in the order in which they appear on the
 command line.

 If |insertion_point| is present, |name| must also be present.


 �

 �

 �#

 �&'
$
 �! The file contents.


 �

 �

 �

 � 
�
 �8� Information describing the file content being inserted. If an insertion
 point is used, this information will be appropriately offset and inserted
 into the code generation metadata for the generated files.


 �

 �

 �2

 �57

�

�


�

�

�
�=
 google/protobuf/field_mask.protogoogle.protobuf"!
	FieldMask
paths (	RpathsB�
com.google.protobufBFieldMaskProtoPZ2google.golang.org/protobuf/types/known/fieldmaskpb��GPB�Google.Protobuf.WellKnownTypesJ�;
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# ,
	
# ,

$ /
	
$ /

% "
	

% "

& !
	
$& !

' I
	
' I

( 
	
( 
�,
 � ��, `FieldMask` represents a set of symbolic field paths, for example:

     paths: "f.a"
     paths: "f.b.d"

 Here `f` represents a field in some root message, `a` and `b`
 fields in the message found in `f`, and `d` a field found in the
 message in `f.b`.

 Field masks are used to specify a subset of fields that should be
 returned by a get operation or modified by an update operation.
 Field masks also have a custom JSON encoding (see below).

 # Field Masks in Projections

 When used in the context of a projection, a response message or
 sub-message is filtered by the API to only contain those fields as
 specified in the mask. For example, if the mask in the previous
 example is applied to a response message as follows:

     f {
       a : 22
       b {
         d : 1
         x : 2
       }
       y : 13
     }
     z: 8

 The result will not contain specific values for fields x,y and z
 (their value will be set to the default, and omitted in proto text
 output):


     f {
       a : 22
       b {
         d : 1
       }
     }

 A repeated field is not allowed except at the last position of a
 paths string.

 If a FieldMask object is not present in a get operation, the
 operation applies to all fields (as if a FieldMask of all fields
 had been specified).

 Note that a field mask does not necessarily apply to the
 top-level response message. In case of a REST get operation, the
 field mask applies directly to the response, but in case of a REST
 list operation, the mask instead applies to each individual message
 in the returned resource list. In case of a REST custom method,
 other definitions may be used. Where the mask applies will be
 clearly documented together with its declaration in the API.  In
 any case, the effect on the returned resource/resources is required
 behavior for APIs.

 # Field Masks in Update Operations

 A field mask in update operations specifies which fields of the
 targeted resource are going to be updated. The API is required
 to only change the values of the fields as specified in the mask
 and leave the others untouched. If a resource is passed in to
 describe the updated values, the API ignores the values of all
 fields not covered by the mask.

 If a repeated field is specified for an update operation, new values will
 be appended to the existing repeated field in the target resource. Note that
 a repeated field is only allowed in the last position of a `paths` string.

 If a sub-message is specified in the last position of the field mask for an
 update operation, then new value will be merged into the existing sub-message
 in the target resource.

 For example, given the target message:

     f {
       b {
         d: 1
         x: 2
       }
       c: [1]
     }

 And an update message:

     f {
       b {
         d: 10
       }
       c: [2]
     }

 then if the field mask is:

  paths: ["f.b", "f.c"]

 then the result will be:

     f {
       b {
         d: 10
         x: 2
       }
       c: [1, 2]
     }

 An implementation may provide options to override this default behavior for
 repeated and message fields.

 In order to reset a field's value to the default, the field must
 be in the mask and set to the default value in the provided resource.
 Hence, in order to reset all fields of a resource, provide a default
 instance of the resource and set all fields in the mask, or do
 not provide a mask as described below.

 If a field mask is not present on update, the operation applies to
 all fields (as if a field mask of all fields has been specified).
 Note that in the presence of schema evolution, this may mean that
 fields the client does not know and has therefore not filled into
 the request will be reset to their default. If this is unwanted
 behavior, a specific service may require a client to always specify
 a field mask, producing an error if not.

 As with get operations, the location of the resource which
 describes the updated values in the request message depends on the
 operation kind. In any case, the effect of the field mask is
 required to be honored by the API.

 ## Considerations for HTTP REST

 The HTTP kind of an update operation which uses a field mask must
 be set to PATCH instead of PUT in order to satisfy HTTP semantics
 (PUT must only be used for full updates).

 # JSON Encoding of Field Masks

 In JSON, a field mask is encoded as a single string where paths are
 separated by a comma. Fields name in each path are converted
 to/from lower-camel naming conventions.

 As an example, consider the following message declarations:

     message Profile {
       User user = 1;
       Photo photo = 2;
     }
     message User {
       string display_name = 1;
       string address = 2;
     }

 In proto a field mask for `Profile` may look as such:

     mask {
       paths: "user.display_name"
       paths: "photo"
     }

 In JSON, the same mask is represented as below:

     {
       mask: "user.displayName,photo"
     }

 # Field Masks and Oneof Fields

 Field masks treat fields in oneofs just as regular fields. Consider the
 following message:

     message SampleMessage {
       oneof test_oneof {
         string name = 4;
         SubMessage sub_message = 9;
       }
     }

 The field mask can be:

     mask {
       paths: "name"
     }

 Or:

     mask {
       paths: "sub_message"
     }

 Note that oneof type names ("test_oneof" in this case) cannot be used in
 paths.

 ## Field Mask Verification

 The implementation of any API method which has a FieldMask type field in the
 request should verify the included field paths, and return an
 `INVALID_ARGUMENT` error if any path is unmappable.


 �
,
  � The set of field mask paths.


  �


  �

  �

  �bproto3
�9
google/rpc/code.proto
google.rpc*�
Code
OK 
	CANCELLED
UNKNOWN
INVALID_ARGUMENT
DEADLINE_EXCEEDED
	NOT_FOUND
ALREADY_EXISTS
PERMISSION_DENIED
UNAUTHENTICATED
RESOURCE_EXHAUSTED
FAILED_PRECONDITION	
ABORTED

OUT_OF_RANGE
UNIMPLEMENTED
INTERNAL
UNAVAILABLE
	DATA_LOSSBX
com.google.rpcB	CodeProtoPZ3google.golang.org/genproto/googleapis/rpc/code;code�RPCJ�5
 �
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 J
	
 J

 "
	

 "

 *
	
 *

 '
	
 '

 !
	
$ !
�
  �� The canonical error codes for gRPC APIs.


 Sometimes multiple error codes may apply.  Services should return
 the most specific error code that applies.  For example, prefer
 `OUT_OF_RANGE` over `FAILED_PRECONDITION` if both codes apply.
 Similarly prefer `NOT_FOUND` or `ALREADY_EXISTS` over `FAILED_PRECONDITION`.



 	
G
  #	: Not an error; returned on success

 HTTP Mapping: 200 OK


  #

  #
n
 (a The operation was cancelled, typically by the caller.

 HTTP Mapping: 499 Client Closed Request


 (

 (
�
 1� Unknown error.  For example, this error may be returned when
 a `Status` value received from another address space belongs to
 an error space that is not known in this address space.  Also
 errors raised by APIs that do not return enough error information
 may be converted to this error.

 HTTP Mapping: 500 Internal Server Error


 1	

 1
�
 9� The client specified an invalid argument.  Note that this differs
 from `FAILED_PRECONDITION`.  `INVALID_ARGUMENT` indicates arguments
 that are problematic regardless of the state of the system
 (e.g., a malformed file name).

 HTTP Mapping: 400 Bad Request


 9

 9
�
 B� The deadline expired before the operation could complete. For operations
 that change the state of the system, this error may be returned
 even if the operation has completed successfully.  For example, a
 successful response from a server could have been delayed long
 enough for the deadline to expire.

 HTTP Mapping: 504 Gateway Timeout


 B

 B
�
 M� Some requested entity (e.g., file or directory) was not found.

 Note to server developers: if a request is denied for an entire class
 of users, such as gradual feature rollout or undocumented whitelist,
 `NOT_FOUND` may be used. If a request is denied for some users within
 a class of users, such as user-based access control, `PERMISSION_DENIED`
 must be used.

 HTTP Mapping: 404 Not Found


 M

 M
�
 Sv The entity that a client attempted to create (e.g., file or directory)
 already exists.

 HTTP Mapping: 409 Conflict


 S

 S
�
 _� The caller does not have permission to execute the specified
 operation. `PERMISSION_DENIED` must not be used for rejections
 caused by exhausting some resource (use `RESOURCE_EXHAUSTED`
 instead for those errors). `PERMISSION_DENIED` must not be
 used if the caller can not be identified (use `UNAUTHENTICATED`
 instead for those errors). This error code does not imply the
 request is valid or the requested entity exists or satisfies
 other pre-conditions.

 HTTP Mapping: 403 Forbidden


 _

 _
~
 eq The request does not have valid authentication credentials for the
 operation.

 HTTP Mapping: 401 Unauthorized


 e

 e
�
 	k� Some resource has been exhausted, perhaps a per-user quota, or
 perhaps the entire file system is out of space.

 HTTP Mapping: 429 Too Many Requests


 	k

 	k
�
 
� The operation was rejected because the system is not in a state
 required for the operation's execution.  For example, the directory
 to be deleted is non-empty, an rmdir operation is applied to
 a non-directory, etc.

 Service implementors can use the following guidelines to decide
 between `FAILED_PRECONDITION`, `ABORTED`, and `UNAVAILABLE`:
  (a) Use `UNAVAILABLE` if the client can retry just the failing call.
  (b) Use `ABORTED` if the client should retry at a higher level
      (e.g., when a client-specified test-and-set fails, indicating the
      client should restart a read-modify-write sequence).
  (c) Use `FAILED_PRECONDITION` if the client should not retry until
      the system state has been explicitly fixed.  E.g., if an "rmdir"
      fails because the directory is non-empty, `FAILED_PRECONDITION`
      should be returned since the client should not retry unless
      the files are deleted from the directory.

 HTTP Mapping: 400 Bad Request


 


 

�
 �� The operation was aborted, typically due to a concurrency issue such as
 a sequencer check failure or transaction abort.

 See the guidelines above for deciding between `FAILED_PRECONDITION`,
 `ABORTED`, and `UNAVAILABLE`.

 HTTP Mapping: 409 Conflict


 �	

 �
�
 �� The operation was attempted past the valid range.  E.g., seeking or
 reading past end-of-file.

 Unlike `INVALID_ARGUMENT`, this error indicates a problem that may
 be fixed if the system state changes. For example, a 32-bit file
 system will generate `INVALID_ARGUMENT` if asked to read at an
 offset that is not in the range [0,2^32-1], but it will generate
 `OUT_OF_RANGE` if asked to read from an offset past the current
 file size.

 There is a fair bit of overlap between `FAILED_PRECONDITION` and
 `OUT_OF_RANGE`.  We recommend using `OUT_OF_RANGE` (the more specific
 error) when it applies so that callers who are iterating through
 a space can easily look for an `OUT_OF_RANGE` error to detect when
 they are done.

 HTTP Mapping: 400 Bad Request


 �

 �
�
 �t The operation is not implemented or is not supported/enabled in this
 service.

 HTTP Mapping: 501 Not Implemented


 �

 �
�
 �� Internal errors.  This means that some invariants expected by the
 underlying system have been broken.  This error code is reserved
 for serious errors.

 HTTP Mapping: 500 Internal Server Error


 �


 �
�
 �� The service is currently unavailable.  This is most likely a
 transient condition, which can be corrected by retrying with
 a backoff. Note that it is not always safe to retry
 non-idempotent operations.

 See the guidelines above for deciding between `FAILED_PRECONDITION`,
 `ABORTED`, and `UNAVAILABLE`.

 HTTP Mapping: 503 Service Unavailable


 �

 �
`
 �R Unrecoverable data loss or corruption.

 HTTP Mapping: 500 Internal Server Error


 �

 �bproto3
�Y
google/rpc/error_details.proto
google.rpcgoogle/protobuf/duration.proto"G
	RetryInfo:
retry_delay (2.google.protobuf.DurationR
retryDelay"H
	DebugInfo#
stack_entries (	RstackEntries
detail (	Rdetail"�
QuotaFailureB

violations (2".google.rpc.QuotaFailure.ViolationR
violationsG
	Violation
subject (	Rsubject 
description (	Rdescription"�
	ErrorInfo
reason (	Rreason
domain (	Rdomain?
metadata (2#.google.rpc.ErrorInfo.MetadataEntryRmetadata;
MetadataEntry
key (	Rkey
value (	Rvalue:8"�
PreconditionFailureI

violations (2).google.rpc.PreconditionFailure.ViolationR
violations[
	Violation
type (	Rtype
subject (	Rsubject 
description (	Rdescription"�

BadRequestP
field_violations (2%.google.rpc.BadRequest.FieldViolationRfieldViolationsH
FieldViolation
field (	Rfield 
description (	Rdescription"O
RequestInfo

request_id (	R	requestId!
serving_data (	RservingData"�
ResourceInfo#
resource_type (	RresourceType#
resource_name (	RresourceName
owner (	Rowner 
description (	Rdescription"o
Help+
links (2.google.rpc.Help.LinkRlinks:
Link 
description (	Rdescription
url (	Rurl"D
LocalizedMessage
locale (	Rlocale
message (	RmessageBl
com.google.rpcBErrorDetailsProtoPZ?google.golang.org/genproto/googleapis/rpc/errdetails;errdetails�RPCJ�M
 �
�
 2� Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  (

 V
	
 V

 "
	

 "

 2
	
 2

 '
	
 '

 !
	
$ !
�
 ' *� Describes when the clients can retry a failed request. Clients could ignore
 the recommendation here or retry when this information is missing from error
 responses.

 It's always recommended that clients should use exponential backoff when
 retrying.

 Clients should wait until `retry_delay` amount of time has passed since
 receiving the error response before retrying.  If retrying requests also
 fail, clients should use an exponential backoff scheme to gradually increase
 the delay between retries based on `retry_delay`, until either a maximum
 number of retries have been reached or a maximum retry delay cap has been
 reached.



 '
X
  )+K Clients should wait at least this long between retrying the same request.


  )

  )&

  ))*
2
- 3& Describes additional debugging info.



-
K
 /$> The stack trace entries indicating where the error occurred.


 /


 /

 /

 /"#
G
2: Additional debugging information provided by the server.


2

2	

2
�
@ U� Describes how a quota check failed.

 For example if a daily limit was exceeded for the calling project,
 a service could respond with a QuotaFailure detail containing the project
 id and the description of the quota limit that was exceeded.  If the
 calling project hasn't enabled the service in the developer console, then
 a service could respond with the project id and set `service_disabled`
 to true.

 Also see RetryInfo and Help types for other details about handling a
 quota failure.



@
�
 CQ} A message type used to describe a single quota violation.  For example, a
 daily quota or a custom quota that was exceeded.


 C

�
  G� The subject on which the quota check failed.
 For example, "clientip:<ip address of client>" or "project:<Google
 developer project id>".


  G


  G

  G
�
 P� A description of how the quota check failed. Clients can use this
 description to find more about the quota configuration in the service's
 public documentation, or find the relevant quota limit to adjust through
 developer console.

 For example: "Service disabled" or "Daily Limit for read operations
 exceeded".


 P


 P

 P
.
 T$! Describes all quota violations.


 T


 T

 T

 T"#
�
o �� Describes the cause of the error with structured details.

 Example of an error when contacting the "pubsub.googleapis.com" API when it
 is not enabled:

     { "reason": "API_DISABLED"
       "domain": "googleapis.com"
       "metadata": {
         "resource": "projects/123",
         "service": "pubsub.googleapis.com"
       }
     }

 This response indicates that the pubsub.googleapis.com API is not enabled.

 Example of an error that is returned when attempting to create a Spanner
 instance in a region that is out of stock:

     { "reason": "STOCKOUT"
       "domain": "spanner.googleapis.com",
       "metadata": {
         "availableRegions": "us-central1,us-east2"
       }
     }



o
�
 t� The reason of the error. This is a constant value that identifies the
 proximate cause of the error. Error reasons are unique within a particular
 domain of errors. This should be at most 63 characters and match
 /[A-Z0-9_]+/.


 t

 t	

 t
�
|� The logical grouping to which the "reason" belongs. The error domain
 is typically the registered service name of the tool or product that
 generates the error. Example: "pubsub.googleapis.com". If the error is
 generated by some common infrastructure, the error domain must be a
 globally unique value that identifies the infrastructure. For Google API
 infrastructure, the error domain is "googleapis.com".


|

|	

|
�
�#� Additional structured details about this error.

 Keys should match /[a-zA-Z0-9-_]/ and be limited to 64 characters in
 length. When identifying the current value of an exceeded limit, the units
 should be contained in the key, not the value.  For example, rather than
 {"instanceLimit": "100/request"}, should be returned as,
 {"instanceLimitPerRequest": "100"}, if the client exceeds the number of
 instances that can be created in a single (batch) request.


�

�

�!"
�
� �� Describes what preconditions have failed.

 For example, if an RPC failed because it required the Terms of Service to be
 acknowledged, it could list the terms of service violation in the
 PreconditionFailure message.


�
P
 ��@ A message type used to describe a single precondition failure.


 �

�
  �� The type of PreconditionFailure. We recommend using a service-specific
 enum type to define the supported precondition violation subjects. For
 example, "TOS" for "Terms of Service violation".


  �


  �

  �
�
 �� The subject, relative to the type, that failed.
 For example, "google.com/cloud" relative to the "TOS" type would indicate
 which terms of service is being referenced.


 �


 �

 �
�
 �� A description of how the precondition failed. Developers can use this
 description to understand how to fix the failure.

 For example: "Terms of service not accepted".


 �


 �

 �
6
 �$( Describes all precondition violations.


 �


 �

 �

 �"#
{
� �m Describes violations in a client request. This error type focuses on the
 syntactic aspects of the request.


�
M
 ��= A message type used to describe a single bad request field.


 �

�
  �� A path leading to a field in the request body. The value will be a
 sequence of dot-separated identifiers that identify a protocol buffer
 field. E.g., "field_violations.field" would identify this field.


  �


  �

  �
B
 �2 A description of why the request element is bad.


 �


 �

 �
=
 �// Describes all violations in a client request.


 �


 �

 �*

 �-.
�
� �v Contains metadata about the request that clients can attach when filing a bug
 or providing other forms of feedback.


�
�
 �� An opaque string that should only be interpreted by the service generating
 it. For example, it can be used to identify requests in the service's logs.


 �

 �	

 �
�
�� Any data that was used to serve this request. For example, an encrypted
 stack trace that can be sent back to the service provider for debugging.


�

�	

�
>
� �0 Describes the resource that is being accessed.


�
�
 �� A name for the type of resource being accessed, e.g. "sql table",
 "cloud storage bucket", "file", "Google calendar"; or the type URL
 of the resource: e.g. "type.googleapis.com/google.pubsub.v1.Topic".


 �

 �	

 �
�
�� The name of the resource being accessed.  For example, a shared calendar
 name: "example.com_4fghdhgsrgh@group.calendar.google.com", if the current
 error is [google.rpc.Code.PERMISSION_DENIED][google.rpc.Code.PERMISSION_DENIED].


�

�	

�
�
�w The owner of the resource (optional).
 For example, "user:<owner email>" or "project:<Google developer project
 id>".


�

�	

�
�
�� Describes what error is encountered when accessing this resource.
 For example, updating a cloud project may require the `writer` permission
 on the developer console project.


�

�	

�
�
� �� Provides links to documentation or for performing an out of band action.

 For example, if a quota check failed with an error indicating the calling
 project hasn't enabled the accessed service, this can contain a URL pointing
 directly to the right place in the developer console to flip the bit.


�
'
 �� Describes a URL link.


 �

1
  �! Describes what the link offers.


  �


  �

  �
&
 � The URL of the link.


 �


 �

 �
X
 �J URL(s) pointing to additional information on handling the current error.


 �


 �

 �

 �
}
	� �o Provides a localized error message that is safe to return to the user
 which can be attached to an RPC error.


	�
�
	 �� The locale used following the specification defined at
 http://www.rfc-editor.org/rfc/bcp/bcp47.txt.
 Examples are: "en-US", "fr-CH", "es-MX"


	 �

	 �	

	 �
@
	�2 The localized error message in the above locale.


	�

	�	

	�bproto3
�
!google/type/calendar_period.protogoogle.type*
CalendarPeriod
CALENDAR_PERIOD_UNSPECIFIED 
DAY
WEEK
	FORTNIGHT	
MONTH
QUARTER
HALF
YEARBx
com.google.typeBCalendarPeriodProtoPZHgoogle.golang.org/genproto/googleapis/type/calendarperiod;calendarperiod�GTPJ�
 7
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 _
	
 _

 "
	

 "

 4
	
 4

 (
	
 (

 !
	
$ !
�
  7� A `CalendarPeriod` represents the abstract concept of a time period that has
 a canonical start. Grammatically, "the start of the current
 `CalendarPeriod`." All calendar times begin at midnight UTC.



 
1
  "$ Undefined period, raises an error.


  

   !

  
 A day.


  

  	
q
 $d A week. Weeks begin on Monday, following
 [ISO 8601](https://en.wikipedia.org/wiki/ISO_week_date).


 $

 $	

�
 )� A fortnight. The first calendar fortnight of the year begins at the start
 of week 1 according to
 [ISO 8601](https://en.wikipedia.org/wiki/ISO_week_date).


 )

 )

 ,
 A month.


 ,

 ,

_
 0R A quarter. Quarters start on dates 1-Jan, 1-Apr, 1-Jul, and 1-Oct of each
 year.


 0	

 0
F
 39 A half-year. Half-years start on dates 1-Jan and 1-Jul.


 3

 3	


 6	 A year.


 6

 6	
bproto3
�1
google/type/color.protogoogle.typegoogle/protobuf/wrappers.proto"v
Color
red (Rred
green (Rgreen
blue (Rblue1
alpha (2.google.protobuf.FloatValueRalphaB`
com.google.typeB
ColorProtoPZ6google.golang.org/genproto/googleapis/type/color;color��GTPJ�/
 �
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  (

 
	
 

 M
	
 M

 "
	

 "

 +
	
 +

 (
	
 (

 !
	
$ !
� 
 � ��  Represents a color in the RGBA color space. This representation is designed
 for simplicity of conversion to/from color representations in various
 languages over compactness. For example, the fields of this representation
 can be trivially provided to the constructor of `java.awt.Color` in Java; it
 can also be trivially provided to UIColor's `+colorWithRed:green:blue:alpha`
 method in iOS; and, with just a little work, it can be easily formatted into
 a CSS `rgba()` string in JavaScript.

 This reference page doesn't carry information about the absolute color
 space
 that should be used to interpret the RGB value (e.g. sRGB, Adobe RGB,
 DCI-P3, BT.2020, etc.). By default, applications should assume the sRGB color
 space.

 When color equality needs to be decided, implementations, unless
 documented otherwise, treat two colors as equal if all their red,
 green, blue, and alpha values each differ by at most 1e-5.

 Example (Java):

      import com.google.type.Color;

      // ...
      public static java.awt.Color fromProto(Color protocolor) {
        float alpha = protocolor.hasAlpha()
            ? protocolor.getAlpha().getValue()
            : 1.0;

        return new java.awt.Color(
            protocolor.getRed(),
            protocolor.getGreen(),
            protocolor.getBlue(),
            alpha);
      }

      public static Color toProto(java.awt.Color color) {
        float red = (float) color.getRed();
        float green = (float) color.getGreen();
        float blue = (float) color.getBlue();
        float denominator = 255.0;
        Color.Builder resultBuilder =
            Color
                .newBuilder()
                .setRed(red / denominator)
                .setGreen(green / denominator)
                .setBlue(blue / denominator);
        int alpha = color.getAlpha();
        if (alpha != 255) {
          result.setAlpha(
              FloatValue
                  .newBuilder()
                  .setValue(((float) alpha) / denominator)
                  .build());
        }
        return resultBuilder.build();
      }
      // ...

 Example (iOS / Obj-C):

      // ...
      static UIColor* fromProto(Color* protocolor) {
         float red = [protocolor red];
         float green = [protocolor green];
         float blue = [protocolor blue];
         FloatValue* alpha_wrapper = [protocolor alpha];
         float alpha = 1.0;
         if (alpha_wrapper != nil) {
           alpha = [alpha_wrapper value];
         }
         return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
      }

      static Color* toProto(UIColor* color) {
          CGFloat red, green, blue, alpha;
          if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
            return nil;
          }
          Color* result = [[Color alloc] init];
          [result setRed:red];
          [result setGreen:green];
          [result setBlue:blue];
          if (alpha <= 0.9999) {
            [result setAlpha:floatWrapperWithValue(alpha)];
          }
          [result autorelease];
          return result;
     }
     // ...

  Example (JavaScript):

     // ...

     var protoToCssColor = function(rgb_color) {
        var redFrac = rgb_color.red || 0.0;
        var greenFrac = rgb_color.green || 0.0;
        var blueFrac = rgb_color.blue || 0.0;
        var red = Math.floor(redFrac * 255);
        var green = Math.floor(greenFrac * 255);
        var blue = Math.floor(blueFrac * 255);

        if (!('alpha' in rgb_color)) {
           return rgbToCssColor(red, green, blue);
        }

        var alphaFrac = rgb_color.alpha.value || 0.0;
        var rgbParams = [red, green, blue].join(',');
        return ['rgba(', rgbParams, ',', alphaFrac, ')'].join('');
     };

     var rgbToCssColor = function(red, green, blue) {
       var rgbNumber = new Number((red << 16) | (green << 8) | blue);
       var hexString = rgbNumber.toString(16);
       var missingZeros = 6 - hexString.length;
       var resultBuilder = ['#'];
       for (var i = 0; i < missingZeros; i++) {
          resultBuilder.push('0');
       }
       resultBuilder.push(hexString);
       return resultBuilder.join('');
     };

     // ...


 �
Q
  �C The amount of red in the color as a value in the interval [0, 1].


  �

  �

  �
S
 �E The amount of green in the color as a value in the interval [0, 1].


 �

 �

 �
R
 �D The amount of blue in the color as a value in the interval [0, 1].


 �

 �

 �
�
 �'� The fraction of this color that should be applied to the pixel. That is,
 the final pixel color is defined by the equation:

   `pixel color = alpha * (this color) + (1.0 - alpha) * (background color)`

 This means that a value of 1.0 corresponds to a solid color, whereas
 a value of 0.0 corresponds to a completely transparent color. This
 uses a wrapper message rather than a simple float scalar so that it is
 possible to distinguish between a default value and the value being unset.
 If omitted, this color object is rendered as a solid color
 (as if the alpha value had been explicitly given a value of 1.0).


 �

 �"

 �%&bproto3
�
google/type/date.protogoogle.type"B
Date
year (Ryear
month (Rmonth
day (RdayB]
com.google.typeB	DateProtoPZ4google.golang.org/genproto/googleapis/type/date;date��GTPJ�
 3
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 K
	
 K

 "
	

 "

 *
	
 *

 (
	
 (

 !
	
$ !
�
 & 3� Represents a whole or partial calendar date, such as a birthday. The time of
 day and time zone are either specified elsewhere or are insignificant. The
 date is relative to the Gregorian Calendar. This can represent one of the
 following:

 * A full date, with non-zero year, month, and day values
 * A month and day value, with a zero year, such as an anniversary
 * A year on its own, with zero month and day values
 * A year and month value, with a zero day, such as a credit card expiration
 date

 Related types are [google.type.TimeOfDay][google.type.TimeOfDay] and
 `google.protobuf.Timestamp`.



 &
`
  )S Year of the date. Must be from 1 to 9999, or 0 to specify a date without
 a year.


  )

  )

  )
f
 -Y Month of a year. Must be from 1 to 12, or 0 to specify a year without a
 month and day.


 -

 -

 -
�
 2� Day of a month. Must be from 1 to 31 and valid for the year and month, or 0
 to specify a year by itself or a year and month where the day isn't
 significant.


 2

 2

 2bproto3
�"
google/type/datetime.protogoogle.typegoogle/protobuf/duration.proto"�
DateTime
year (Ryear
month (Rmonth
day (Rday
hours (Rhours
minutes (Rminutes
seconds (Rseconds
nanos (Rnanos:

utc_offset (2.google.protobuf.DurationH R	utcOffset4
	time_zone	 (2.google.type.TimeZoneH RtimeZoneB
time_offset"4
TimeZone
id (	Rid
version (	RversionBi
com.google.typeBDateTimeProtoPZ<google.golang.org/genproto/googleapis/type/datetime;datetime��GTPJ�
 g
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  (

 
	
 

 S
	
 S

 "
	

 "

 .
	
 .

 (
	
 (

 !
	
$ !
�
 3 ]� Represents civil time (or occasionally physical time).

 This type can represent a civil time in one of a few possible ways:

  * When utc_offset is set and time_zone is unset: a civil time on a calendar
    day with a particular offset from UTC.
  * When time_zone is set and utc_offset is unset: a civil time on a calendar
    day in a particular time zone.
  * When neither time_zone nor utc_offset is set: a civil time on a calendar
    day in local time.

 The date is relative to the Proleptic Gregorian Calendar.

 If year is 0, the DateTime is considered not to have a specific year. month
 and day must have valid, non-zero values.

 This type may also be used to represent a physical time if all the date and
 time fields are set and either case of the `time_offset` oneof is set.
 Consider using `Timestamp` message for physical time instead. If your use
 case also would like to store the user's timezone, that can be done in
 another field.

 This type is more flexible than some applications may want. Make sure to
 document and validate your application's limitations.



 3
m
  6` Optional. Year of date. Must be from 1 to 9999, or 0 if specifying a
 datetime without a year.


  6

  6

  6
=
 90 Required. Month of year. Must be from 1 to 12.


 9

 9

 9
^
 =Q Required. Day of month. Must be from 1 to 31 and valid for the year and
 month.


 =

 =

 =
�
 B� Required. Hours of day in 24 hour format. Should be from 0 to 23. An API
 may choose to allow the value "24:00:00" for scenarios like business
 closing time.


 B

 B

 B
F
 E9 Required. Minutes of hour of day. Must be from 0 to 59.


 E

 E

 E
�
 I� Required. Seconds of minutes of the time. Must normally be from 0 to 59. An
 API may allow the value 60 if it allows leap-seconds.


 I

 I

 I
]
 MP Required. Fractions of seconds in nanoseconds. Must be from 0 to
 999,999,999.


 M

 M

 M
�
  T\� Optional. Specifies either the UTC offset or the time zone of the DateTime.
 Choose carefully between them, considering that time zone data may change
 in the future (for example, a country modifies their DST start/end dates,
 and future DateTimes in the affected range had already been stored).
 If omitted, the DateTime is considered to be in local time.


  T
�
 X,� UTC offset. Must be whole seconds, between -18 hours and +18 hours.
 For example, a UTC offset of -4:00 would be represented as
 { seconds: -14400 }.


 X

 X'

 X*+

 [ Time zone.


 [

 [

 [
j
a g^ Represents a time zone from the
 [IANA Time Zone Database](https://www.iana.org/time-zones).



a
J
 c= IANA Time Zone Database time zone, e.g. "America/New_York".


 c

 c	

 c
N
fA Optional. IANA Time Zone Database version number, e.g. "2019a".


f

f	

fbproto3
�
google/type/dayofweek.protogoogle.type*�
	DayOfWeek
DAY_OF_WEEK_UNSPECIFIED 

MONDAY
TUESDAY
	WEDNESDAY
THURSDAY

FRIDAY
SATURDAY

SUNDAYBi
com.google.typeBDayOfWeekProtoPZ>google.golang.org/genproto/googleapis/type/dayofweek;dayofweek�GTPJ�	
 1
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 U
	
 U

 "
	

 "

 /
	
 /

 (
	
 (

 !
	
$ !
+
  1 Represents a day of the week.



 
2
  % The day of the week is unspecified.


  

  

  Monday


 

 

 !	 Tuesday


 !	

 !

 $ Wednesday


 $

 $

 '
 Thursday


 '


 '

 * Friday


 *

 *

 -
 Saturday


 -


 -

 0 Sunday


 0

 0bproto3
�
google/type/decimal.protogoogle.type"
Decimal
value (	RvalueBf
com.google.typeBDecimalProtoPZ:google.golang.org/genproto/googleapis/type/decimal;decimal��GTPJ�
 ^
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 Q
	
 Q

 "
	

 "

 -
	
 -

 (
	
 (

 !
	
$ !
�
   ^� A representation of a decimal value, such as 2.5. Clients may convert values
 into language-native decimal formats, such as Java's [BigDecimal][] or
 Python's [decimal.Decimal][].

 [BigDecimal]:
 https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/math/BigDecimal.html
 [decimal.Decimal]: https://docs.python.org/3/library/decimal.html



  
�
  ]� The decimal value, as a string.

 The string representation consists of an optional sign, `+` (`U+002B`)
 or `-` (`U+002D`), followed by a sequence of zero or more decimal digits
 ("the integer"), optionally followed by a fraction, optionally followed
 by an exponent.

 The fraction consists of a decimal point followed by zero or more decimal
 digits. The string must contain at least one digit in either the integer
 or the fraction. The number formed by the sign, the integer and the
 fraction is referred to as the significand.

 The exponent consists of the character `e` (`U+0065`) or `E` (`U+0045`)
 followed by one or more decimal digits.

 Services **should** normalize decimal values before storing them by:

   - Removing an explicitly-provided `+` sign (`+2.5` -> `2.5`).
   - Replacing a zero-length integer value with `0` (`.5` -> `0.5`).
   - Coercing the exponent character to lower-case (`2.5E8` -> `2.5e8`).
   - Removing an explicitly-provided zero exponent (`2.5e0` -> `2.5`).

 Services **may** perform additional normalization based on its own needs
 and the internal decimal implementation selected, such as shifting the
 decimal point and exponent value together (example: `2.5e-1` <-> `0.25`).
 Additionally, services **may** preserve trailing zeroes in the fraction
 to indicate increased precision, but are not required to do so.

 Note that only the `.` character is supported to divide the integer
 and the fraction; `,` **should not** be supported regardless of locale.
 Additionally, thousand separators **should not** be supported. If a
 service does support them, values **must** be normalized.

 The ENBF grammar is:

     DecimalString =
       [Sign] Significand [Exponent];

     Sign = '+' | '-';

     Significand =
       Digits ['.'] [Digits] | [Digits] '.' Digits;

     Exponent = ('e' | 'E') [Sign] Digits;

     Digits = { '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' };

 Services **should** clearly document the range of supported values, the
 maximum supported precision (total number of digits), and, if applicable,
 the scale (number of digits after the decimal point), as well as how it
 behaves when receiving out-of-bounds values.

 Services **may** choose to accept values passed as input even when the
 value has a higher precision or scale than the service supports, and
 **should** round the value to fit the supported scale. Alternatively, the
 service **may** error with `400 Bad Request` (`INVALID_ARGUMENT` in gRPC)
 if precision would be lost.

 Services **should** error with `400 Bad Request` (`INVALID_ARGUMENT` in
 gRPC) if the service receives a value outside of the supported range.


  ]

  ]	

  ]bproto3
�
google/type/expr.protogoogle.type"z
Expr

expression (	R
expression
title (	Rtitle 
description (	Rdescription
location (	RlocationBZ
com.google.typeB	ExprProtoPZ4google.golang.org/genproto/googleapis/type/expr;expr�GTPJ�
 H
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 K
	
 K

 "
	

 "

 *
	
 *

 (
	
 (

 !
	
$ !
�	
 7 H�	 Represents a textual expression in the Common Expression Language (CEL)
 syntax. CEL is a C-like expression language. The syntax and semantics of CEL
 are documented at https://github.com/google/cel-spec.

 Example (Comparison):

     title: "Summary size limit"
     description: "Determines if a summary is less than 100 chars"
     expression: "document.summary.size() < 100"

 Example (Equality):

     title: "Requestor is owner"
     description: "Determines if requestor is the document owner"
     expression: "document.owner == request.auth.claims.email"

 Example (Logic):

     title: "Public documents"
     description: "Determine whether the document should be publicly visible"
     expression: "document.type != 'private' && document.type != 'internal'"

 Example (Data Manipulation):

     title: "Notification string"
     description: "Create a notification string with a timestamp."
     expression: "'New message received at ' + string(document.create_time)"

 The exact variables and functions that may be referenced within an expression
 are determined by the service that evaluates it. See the service
 documentation for additional information.



 7
]
  :P Textual representation of an expression in Common Expression Language
 syntax.


  :

  :	

  :
�
 ?� Optional. Title for the expression, i.e. a short string describing
 its purpose. This can be used e.g. in UIs which allow to enter the
 expression.


 ?

 ?	

 ?
�
 C� Optional. Description of the expression. This is a longer text which
 describes the expression, e.g. when hovered over it in a UI.


 C

 C	

 C
�
 G Optional. String indicating the location of the expression for error
 reporting, e.g. a file name and a position in the file.


 G

 G	

 Gbproto3
�	
google/type/fraction.protogoogle.type"J
Fraction
	numerator (R	numerator 
denominator (RdenominatorBf
com.google.typeBFractionProtoPZ<google.golang.org/genproto/googleapis/type/fraction;fraction�GTPJ�
  
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 S
	
 S

 "
	

 "

 .
	
 .

 (
	
 (

 !
	
$ !
U
   I Represents a fraction in terms of a numerator divided by a denominator.



 
<
  / The numerator in the fraction, e.g. 2 in 2/3.


  

  

  
]
 P The value by which the numerator is divided, e.g. 3 in 2/3. Must be
 positive.


 

 

 bproto3
�
google/type/interval.protogoogle.typegoogle/protobuf/timestamp.proto"|
Interval9

start_time (2.google.protobuf.TimestampR	startTime5
end_time (2.google.protobuf.TimestampRendTimeBi
com.google.typeBIntervalProtoPZ<google.golang.org/genproto/googleapis/type/interval;interval��GTPJ�
 -
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  )

 
	
 

 S
	
 S

 "
	

 "

 .
	
 .

 (
	
 (

 !
	
$ !
�
 ! -� Represents a time interval, encoded as a Timestamp start (inclusive) and a
 Timestamp end (exclusive).

 The start must be less than or equal to the end.
 When the start equals the end, the interval is empty (matches no time).
 When both start and end are unspecified, the interval matches any time.



 !
�
  &+� Optional. Inclusive start of the interval.

 If specified, a Timestamp matching this interval will have to be the same
 or after the start.


  &

  &&

  &)*
�
 ,)~ Optional. Exclusive end of the interval.

 If specified, a Timestamp matching this interval will have to be before the
 end.


 ,

 ,$

 ,'(bproto3
�

 google/type/localized_text.protogoogle.type"H
LocalizedText
text (	Rtext#
language_code (	RlanguageCodeBz
com.google.typeBLocalizedTextProtoPZHgoogle.golang.org/genproto/googleapis/type/localized_text;localized_text��GTPJ�
 #
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 _
	
 _

 "
	

 "

 3
	
 3

 (
	
 (

 !
	
$ !
C
  #7 Localized variant of a text in a particular language.



 
W
  J Localized string in the language corresponding to `language_code' below.


  

  	

  
�
 "� The text's BCP-47 language code, such as "en-US" or "sr-Latn".

 For more information, see
 http://www.unicode.org/reports/tr35/#Unicode_locale_identifier.


 "

 "	

 "bproto3
�
google/type/money.protogoogle.type"X
Money#
currency_code (	RcurrencyCode
units (Runits
nanos (RnanosB`
com.google.typeB
MoneyProtoPZ6google.golang.org/genproto/googleapis/type/money;money��GTPJ�
 )
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 M
	
 M

 "
	

 "

 +
	
 +

 (
	
 (

 !
	
$ !
C
  )7 Represents an amount of money with its currency type.



 
B
  5 The three-letter currency code defined in ISO 4217.


  

  	

  
v
  i The whole units of the amount.
 For example if `currencyCode` is `"USD"`, then 1 unit is one US dollar.


  

  

  
�
 (� Number of nano (10^-9) units of the amount.
 The value must be between -999,999,999 and +999,999,999 inclusive.
 If `units` is positive, `nanos` must be positive or zero.
 If `units` is zero, `nanos` can be positive, zero, or negative.
 If `units` is negative, `nanos` must be negative or zero.
 For example $-1.75 is represented as `units`=-1 and `nanos`=-750,000,000.


 (

 (

 (bproto3
�
google/type/month.protogoogle.type*�
Month
MONTH_UNSPECIFIED 
JANUARY
FEBRUARY	
MARCH	
APRIL
MAY
JUNE
JULY

AUGUST
	SEPTEMBER	
OCTOBER

NOVEMBER
DECEMBERB]
com.google.typeB
MonthProtoPZ6google.golang.org/genproto/googleapis/type/month;month�GTPJ�
 @
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 M
	
 M

 "
	

 "

 +
	
 +

 (
	
 (

 !
	
$ !
;
  @/ Represents a month in the Gregorian calendar.



 

%
   The unspecified month.


  

  
$
  The month of January.


 	

 
%
 ! The month of February.


 !


 !
"
 $ The month of March.


 $

 $

"
 ' The month of April.


 '

 '

 
 *
 The month of May.


 *

 *	
!
 - The month of June.


 -

 -	

!
 0 The month of July.


 0

 0	

#
 3 The month of August.


 3

 3
&
 	6 The month of September.


 	6

 	6
$
 
9 The month of October.


 
9	

 
9
%
 < The month of November.


 <


 <
%
 ? The month of December.


 ?


 ?bproto3
�%
google/type/phone_number.protogoogle.type"�
PhoneNumber!
e164_number (	H R
e164NumberC

short_code (2".google.type.PhoneNumber.ShortCodeH R	shortCode
	extension (	R	extensionD
	ShortCode
region_code (	R
regionCode
number (	RnumberB
kindBt
com.google.typeBPhoneNumberProtoPZDgoogle.golang.org/genproto/googleapis/type/phone_number;phone_number��GTPJ�"
 p
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 [
	
 [

 "
	

 "

 1
	
 1

 (
	
 (

 !
	
$ !
�
 3 p� An object representing a phone number, suitable as an API wire format.

 This representation:

  - should not be used for locale-specific formatting of a phone number, such
    as "+1 (650) 253-0000 ext. 123"

  - is not designed for efficient storage
  - may not be suitable for dialing - specialized libraries (see references)
    should be used to parse the number for that purpose

 To do something meaningful with this number, such as format it for various
 use-cases, convert it to an `i18n.phonenumbers.PhoneNumber` object first.

 For instance, in Java this would be:

    com.google.type.PhoneNumber wireProto =
        com.google.type.PhoneNumber.newBuilder().build();
    com.google.i18n.phonenumbers.Phonenumber.PhoneNumber phoneNumber =
        PhoneNumberUtil.getInstance().parse(wireProto.getE164Number(), "ZZ");
    if (!wireProto.getExtension().isEmpty()) {
      phoneNumber.setExtension(wireProto.getExtension());
    }

  Reference(s):
   - https://github.com/google/libphonenumber



 3
�
  =H� An object representing a short code, which is a phone number that is
 typically much shorter than regular phone numbers and can be used to
 address messages in MMS and SMS systems, as well as for abbreviated dialing
 (e.g. "Text 611 to see how many minutes you have remaining on your plan.").

 Short codes are restricted to a region and are not internationally
 dialable, which means the same short code can exist in different regions,
 with different usage and pricing, even if those regions share the same
 country calling code (e.g. US and CA).


  =

�
   C� Required. The BCP-47 region code of the location where calls to this
 short code can be made, such as "US" and "BB".

 Reference(s):
  - http://www.unicode.org/reports/tr35/#unicode_region_subtag


   C


   C

   C
t
  Ge Required. The short code digits, without a leading plus ('+') or country
 calling code, e.g. "611".


  G


  G

  G
�
  Md� Required.  Either a regular number, or a short code.  New fields may be
 added to the oneof below in the future, so clients should ignore phone
 numbers for which none of the fields they coded against are set.


  M
�
  ]� The phone number, represented as a leading plus sign ('+'), followed by a
 phone number that uses a relaxed ITU E.164 format consisting of the
 country calling code (1 to 3 digits) and the subscriber number, with no
 additional spaces or formatting, e.g.:
  - correct: "+15552220123"
  - incorrect: "+1 (555) 222-01234 x123".

 The ITU E.164 format limits the latter to 12 digits, but in practice not
 all countries respect that, so we relax that restriction here.
 National-only numbers are not allowed.

 References:
  - https://www.itu.int/rec/T-REC-E.164-201011-I
  - https://en.wikipedia.org/wiki/E.164.
  - https://en.wikipedia.org/wiki/List_of_country_calling_codes


  ]


  ]

  ]
Y
 cL A short code.

 Reference(s):
  - https://en.wikipedia.org/wiki/Short_code


 c

 c

 c
�
 o� The phone number's extension. The extension is not standardized in ITU
 recommendations, except for being defined as a series of numbers with a
 maximum length of 40 digits. Other than digits, some other dialing
 characters such as ',' (indicating a wait) or '#' may be stored here.

 Note that no regions currently use extensions with short codes, so this
 field is normally only set in conjunction with an E.164 number. It is held
 separately from the E.164 number to allow for short code extensions in the
 future.


 o

 o	

 obproto3
�4
 google/type/postal_address.protogoogle.type"�
PostalAddress
revision (Rrevision
region_code (	R
regionCode#
language_code (	RlanguageCode
postal_code (	R
postalCode!
sorting_code (	RsortingCode/
administrative_area (	RadministrativeArea
locality (	Rlocality 
sublocality (	Rsublocality#
address_lines	 (	RaddressLines

recipients
 (	R
recipients"
organization (	RorganizationBx
com.google.typeBPostalAddressProtoPZFgoogle.golang.org/genproto/googleapis/type/postaladdress;postaladdress��GTPJ�/
 �
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 ]
	
 ]

 "
	

 "

 3
	
 3

 (
	
 (

 !
	
$ !
�
 * �� Represents a postal address, e.g. for postal delivery or payments addresses.
 Given a postal address, a postal service can deliver items to a premise, P.O.
 Box or similar.
 It is not intended to model geographical locations (roads, towns,
 mountains).

 In typical usage an address would be created via user input or from importing
 existing data, depending on the type of process.

 Advice on address input / editing:
  - Use an i18n-ready address widget such as
    https://github.com/google/libaddressinput)
 - Users should not be presented with UI elements for input or editing of
   fields outside countries where that field is used.

 For more guidance on how to use this schema, please see:
 https://support.google.com/business/answer/6397478



 *
�
  /� The schema revision of the `PostalAddress`. This must be set to 0, which is
 the latest revision.

 All new revisions **must** be backward compatible with old revisions.


  /

  /

  /
�
 6� Required. CLDR region code of the country/region of the address. This
 is never inferred and it is up to the user to ensure the value is
 correct. See http://cldr.unicode.org/ and
 http://www.unicode.org/cldr/charts/30/supplemental/territory_information.html
 for details. Example: "CH" for Switzerland.


 6

 6	

 6
�
 D� Optional. BCP-47 language code of the contents of this address (if
 known). This is often the UI language of the input form or is expected
 to match one of the languages used in the address' country/region, or their
 transliterated equivalents.
 This can affect formatting in certain countries, but is not critical
 to the correctness of the data and will never affect any validation or
 other non-formatting related operations.

 If this value is not known, it should be omitted (rather than specifying a
 possibly incorrect default).

 Examples: "zh-Hant", "ja", "ja-Latn", "en".


 D

 D	

 D
�
 J� Optional. Postal code of the address. Not all countries use or require
 postal codes to be present, but where they are used, they may trigger
 additional validation with other parts of the address (e.g. state/zip
 validation in the U.S.A.).


 J

 J	

 J
�
 Q� Optional. Additional, country-specific, sorting code. This is not used
 in most regions. Where it is used, the value is either a string like
 "CEDEX", optionally followed by a number (e.g. "CEDEX 7"), or just a number
 alone, representing the "sector code" (Jamaica), "delivery area indicator"
 (Malawi) or "post office indicator" (e.g. Côte d'Ivoire).


 Q

 Q	

 Q
�
 Z!� Optional. Highest administrative subdivision which is used for postal
 addresses of a country or region.
 For example, this can be a state, a province, an oblast, or a prefecture.
 Specifically, for Spain this is the province and not the autonomous
 community (e.g. "Barcelona" and not "Catalonia").
 Many countries don't use an administrative area in postal addresses. E.g.
 in Switzerland this should be left unpopulated.


 Z

 Z	

 Z 
�
 `� Optional. Generally refers to the city/town portion of the address.
 Examples: US city, IT comune, UK post town.
 In regions of the world where localities are not well defined or do not fit
 into this structure well, leave locality empty and use address_lines.


 `

 `	

 `
r
 de Optional. Sublocality of the address.
 For example, this can be neighborhoods, boroughs, districts.


 d

 d	

 d
�	
 |$�	 Unstructured address lines describing the lower levels of an address.

 Because values in address_lines do not have type information and may
 sometimes contain multiple values in a single field (e.g.
 "Austin, TX"), it is important that the line order is clear. The order of
 address lines should be "envelope order" for the country/region of the
 address. In places where this can vary (e.g. Japan), address_language is
 used to make it explicit (e.g. "ja" for large-to-small ordering and
 "ja-Latn" or "en" for small-to-large). This way, the most specific line of
 an address can be selected based on the language.

 The minimum permitted structural representation of an address consists
 of a region_code with all remaining information placed in the
 address_lines. It would be possible to format such an address very
 approximately without geocoding, but no semantic reasoning could be
 made about any of the address components until it was at least
 partially resolved.

 Creating an address only containing a region_code and address_lines, and
 then geocoding is the recommended way to handle completely unstructured
 addresses (as opposed to guessing which parts of the address should be
 localities or administrative areas).


 |


 |

 |

 |"#
�
 	�"� Optional. The recipient at the address.
 This field may, under certain circumstances, contain multiline information.
 For example, it might contain "care of" information.


 	�


 	�

 	�

 	�!
F
 
�8 Optional. The name of the organization at the address.


 
�

 
�	

 
�bproto3
�
google/type/quaternion.protogoogle.type"D

Quaternion
x (Rx
y (Ry
z (Rz
w (RwBo
com.google.typeBQuaternionProtoPZ@google.golang.org/genproto/googleapis/type/quaternion;quaternion��GTPJ�
 ]
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 W
	
 W

 "
	

 "

 0
	
 0

 (
	
 (

 !
	
$ !
�
 Q ]� A quaternion is defined as the quotient of two directed lines in a
 three-dimensional space or equivalently as the quotient of two Euclidean
 vectors (https://en.wikipedia.org/wiki/Quaternion).

 Quaternions are often used in calculations involving three-dimensional
 rotations (https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation),
 as they provide greater mathematical robustness by avoiding the gimbal lock
 problems that can be encountered when using Euler angles
 (https://en.wikipedia.org/wiki/Gimbal_lock).

 Quaternions are generally represented in this form:

     w + xi + yj + zk

 where x, y, z, and w are real numbers, and i, j, and k are three imaginary
 numbers.

 Our naming choice `(x, y, z, w)` comes from the desire to avoid confusion for
 those interested in the geometric properties of the quaternion in the 3D
 Cartesian space. Other texts often use alternative names or subscripts, such
 as `(a, b, c, d)`, `(1, i, j, k)`, or `(0, 1, 2, 3)`, which are perhaps
 better suited for mathematical interpretations.

 To avoid any confusion, as well as to maintain compatibility with a large
 number of software libraries, the quaternions represented using the protocol
 buffer below *must* follow the Hamilton convention, which defines `ij = k`
 (i.e. a right-handed algebra), and therefore:

     i^2 = j^2 = k^2 = ijk = −1
     ij = −ji = k
     jk = −kj = i
     ki = −ik = j

 Please DO NOT use this to represent quaternions that follow the JPL
 convention, or any of the other quaternion flavors out there.

 Definitions:

   - Quaternion norm (or magnitude): `sqrt(x^2 + y^2 + z^2 + w^2)`.
   - Unit (or normalized) quaternion: a quaternion whose norm is 1.
   - Pure quaternion: a quaternion whose scalar component (`w`) is 0.
   - Rotation quaternion: a unit quaternion used to represent rotation.
   - Orientation quaternion: a unit quaternion used to represent orientation.

 A quaternion can be normalized by dividing it by its norm. The resulting
 quaternion maintains the same direction, but has a norm of 1, i.e. it moves
 on the unit sphere. This is generally necessary for rotation and orientation
 quaternions, to avoid rounding errors:
 https://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions

 Note that `(x, y, z, w)` and `(-x, -y, -z, -w)` represent the same rotation,
 but normalization would be even more useful, e.g. for comparison purposes, if
 it would produce a unique representation. It is thus recommended that `w` be
 kept positive, which can be achieved by changing all the signs when `w` is
 negative.




 Q

  S The x component.


  S

  S	


  S

 V The y component.


 V

 V	


 V

 Y The z component.


 Y

 Y	


 Y
$
 \ The scalar component.


 \

 \	


 \bproto3
�
google/type/timeofday.protogoogle.type"k
	TimeOfDay
hours (Rhours
minutes (Rminutes
seconds (Rseconds
nanos (RnanosBl
com.google.typeBTimeOfDayProtoPZ>google.golang.org/genproto/googleapis/type/timeofday;timeofday��GTPJ�
 +
�
 2� Copyright 2021 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 

 
	
 

 U
	
 U

 "
	

 "

 /
	
 /

 (
	
 (

 !
	
$ !
�
  +� Represents a time of day. The date and time zone are either not significant
 or are specified elsewhere. An API may choose to allow leap seconds. Related
 types are [google.type.Date][google.type.Date] and
 `google.protobuf.Timestamp`.



 
�
   � Hours of day in 24 hour format. Should be from 0 to 23. An API may choose
 to allow the value "24:00:00" for scenarios like business closing time.


   

   

   
<
 #/ Minutes of hour of day. Must be from 0 to 59.


 #

 #

 #
�
 'z Seconds of minutes of the time. Must normally be from 0 to 59. An API may
 allow the value 60 if it allows leap-seconds.


 '

 '

 '
R
 *E Fractions of seconds in nanoseconds. Must be from 0 to 999,999,999.


 *

 *

 *bproto3
�

grpc.proto
com.am.appgoogle/api/annotations.proto"'
CreateUserRequest
name (	Rname".
CreateUserResponse
message (	Rmessage2s
UserServiced

createUser.com.am.app.CreateUserRequest.com.am.app.CreateUserResponse"���"/api/v1/user:*B

com.am.appBDemoP�HLWJ�
  

  

 "
	

 "

 #
	
 #

 %
	
 %

 !
	
$ !

 
	
 	 &


  


 

  

  

  #

  .@

  

	  �ʼ"


  


 

  

  

  	

  


 




 

 

 	

 bproto3
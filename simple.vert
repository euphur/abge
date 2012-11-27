// Very Simple Vertex Shader
#version 330

in vec3 vVertex;
in vec3 vColor;
uniform mat4 mModelView;

out vec3 vVaryingColor;

void main(void)
{
  // vVaryingColor = vec4(0,green,0,1); //vColor;
  //  vVaryingColor = vColor;
  gl_Position = mModelView * vec4(vVertex, 1.0);
  vVaryingColor = vec3(1,0,0) * max(0.0, dot(normalize(vec3(1,1,1)), normalize(gl_Position.xyz)));
}

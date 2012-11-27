// Very Simple Fragment Shader
#version 330

in vec3 vVaryingColor;
out vec3 vFragColor;

void main(void)
{
  vFragColor = vVaryingColor;
}

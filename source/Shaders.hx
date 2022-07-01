package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

using StringTools;

class ChromaticAberrationEffect
{
	public var shader:ChromaticAberrationShader;

	public function new(offset:Float = 0.00)
	{
		shader = new ChromaticAberrationShader();
		shader.data.rOffset.value = [offset];
		shader.data.gOffset.value = [0.0];
		shader.data.bOffset.value = [-offset];
	}
}

class ChromaticAberrationShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.g;
			toUse.b = col3.b;
			//float someshit = col4.r + col4.g + col4.b;

			gl_FragColor = toUse;
		}')
	public function new()
	{
		super();
	}
}

class StaticEffect
{
	public var shader:StaticShader;

	public function new()
	{
		shader = new StaticShader();
	}
}

class StaticShader extends FlxShader
{
	// https://www.shadertoy.com/view/tdXXRM

	@:glFragmentSource('
	#pragma header

    uniform float iTime;
    uniform vec3 iResolution; 
    
    float Noise21 (vec2 p, float ta, float tb) {
        return fract(sin(p.x*ta+p.y*tb)*5678.);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;

        float t = iTime+123.; // tweak the start moment
        float ta = t*.654321;
        float tb = t*(ta*.123456);
        
        float c = Noise21(uv, ta, tb);
        vec3 col = vec3(c);

        gl_FragColor = vec4(col,1.);
    }
	')
	public function new()
	{
		super();
	}
}
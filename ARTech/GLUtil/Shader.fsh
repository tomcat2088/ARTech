//
//  Shader.fsh
//  OpenESRD
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 wangyang. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 uvVarying;
varying highp float lightStrength;

uniform sampler2D s_texture;

void main()
{
//    gl_FragColor = colorVarying * 0.4 + texture2D( s_texture,uvVarying ) * lightStrength* 0.6;
    gl_FragColor = colorVarying * 0.4 + texture2D( s_texture,uvVarying ) * 0.6;
}

#import "GPUImageFourInputFilter.h"

extern NSString *const kGPUImageEightInputTextureVertexShaderString;

@interface GPUImageEightInputFilter : GPUImageFourInputFilter
{
    GPUImageFramebuffer *fifthInputFramebuffer;
    GPUImageFramebuffer *sixthInputFramebuffer;
    GPUImageFramebuffer *seventhInputFramebuffer;
    GPUImageFramebuffer *eighthInputFramebuffer;

    GLint filterFifthTextureCoordinateAttribute;
    GLint filterSixthTextureCoordinateAttribute;
    GLint filterSeventhTextureCoordinateAttribute;
    GLint filterEighthTextureCoordinateAttribute;

    GLint filterInputTextureUniform5;
    GLint filterInputTextureUniform6;
    GLint filterInputTextureUniform7;
    GLint filterInputTextureUniform8;

    GPUImageRotationMode inputRotation5;
    GPUImageRotationMode inputRotation6;
    GPUImageRotationMode inputRotation7;
    GPUImageRotationMode inputRotation8;

    GLuint filterSourceTexture5;
    GLuint filterSourceTexture6;
    GLuint filterSourceTexture7;
    GLuint filterSourceTexture8;

    CMTime fifthFrameTime;
    CMTime sixthFrameTime;
    CMTime seventhFrameTime;
    CMTime eighthFrameTime;

    BOOL hasSetFourthTexture,  hasReceivedFifthFrame,   fifthFrameWasVideo;
    BOOL hasSetFifthTexture,   hasReceivedSixthFrame,   sixthFrameWasVideo;
    BOOL hasSetSixthTexture,   hasReceivedSeventhFrame, seventhFrameWasVideo;
    BOOL hasSetSeventhTexture, hasReceivedEighthFrame,  eighthFrameWasVideo;

    BOOL fifthFrameCheckDisabled;
    BOOL sixthFrameCheckDisabled;
    BOOL seventhFrameCheckDisabled;
    BOOL eighthFrameCheckDisabled;
}

- (void)disableFifthFrameCheck;
- (void)disableSixthFrameCheck;
- (void)disableSeventhFrameCheck;
- (void)disableEighthFrameCheck;

@end
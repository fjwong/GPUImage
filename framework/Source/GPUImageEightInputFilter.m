#import "GPUImageEightInputFilter.h"


NSString *const kGPUImageEightInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 attribute vec4 inputTextureCoordinate3;
 attribute vec4 inputTextureCoordinate4;
 attribute vec4 inputTextureCoordinate5;
 attribute vec4 inputTextureCoordinate6;
 attribute vec4 inputTextureCoordinate7;
 attribute vec4 inputTextureCoordinate8;

 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 varying vec2 textureCoordinate4;
 varying vec2 textureCoordinate5;
 varying vec2 textureCoordinate6;
 varying vec2 textureCoordinate7;
 varying vec2 textureCoordinate8;

 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
     textureCoordinate3 = inputTextureCoordinate3.xy;
     textureCoordinate4 = inputTextureCoordinate4.xy;
     textureCoordinate5 = inputTextureCoordinate5.xy;
     textureCoordinate6 = inputTextureCoordinate6.xy;
     textureCoordinate7 = inputTextureCoordinate7.xy;
     textureCoordinate8 = inputTextureCoordinate8.xy;
 }
);

@implementation GPUImageEightInputFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [self initWithVertexShaderFromString:kGPUImageEightInputTextureVertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }

    return self;
}

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }

    inputRotation5 = kGPUImageNoRotation;
    inputRotation6 = kGPUImageNoRotation;
    inputRotation7 = kGPUImageNoRotation;
    inputRotation8 = kGPUImageNoRotation;

    hasSetFourthTexture = NO;
    hasSetFifthTexture = NO;
    hasSetSixthTexture = NO;
    hasSetSeventhTexture = NO;

    hasReceivedFifthFrame = NO;
    hasReceivedSixthFrame = NO;
    hasReceivedSeventhFrame = NO;
    hasReceivedEighthFrame = NO;

    fifthFrameWasVideo = NO;
    sixthFrameWasVideo = NO;
    seventhFrameWasVideo = NO;
    eighthFrameWasVideo = NO;

    fifthFrameCheckDisabled = NO;
    sixthFrameCheckDisabled = NO;
    seventhFrameCheckDisabled = NO;
    eighthFrameCheckDisabled = NO;

    fifthFrameTime = kCMTimeInvalid;
    sixthFrameTime = kCMTimeInvalid;
    seventhFrameTime = kCMTimeInvalid;
    eighthFrameTime = kCMTimeInvalid;

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        filterFifthTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate5"];
        filterSixthTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate6"];
        filterSeventhTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate7"];
        filterEighthTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate8"];

        filterInputTextureUniform5 = [filterProgram uniformIndex:@"inputImageTexture5"];
        filterInputTextureUniform6 = [filterProgram uniformIndex:@"inputImageTexture6"];
        filterInputTextureUniform7 = [filterProgram uniformIndex:@"inputImageTexture7"];
        filterInputTextureUniform8 = [filterProgram uniformIndex:@"inputImageTexture8"];

        glEnableVertexAttribArray(filterFifthTextureCoordinateAttribute);
        glEnableVertexAttribArray(filterSixthTextureCoordinateAttribute);
        glEnableVertexAttribArray(filterSeventhTextureCoordinateAttribute);
        glEnableVertexAttribArray(filterEighthTextureCoordinateAttribute);
    });

    return self;
}

- (void)initializeAttributes;
{
    [super initializeAttributes];
    [filterProgram addAttribute:@"inputTextureCoordinate5"];
    [filterProgram addAttribute:@"inputTextureCoordinate6"];
    [filterProgram addAttribute:@"inputTextureCoordinate7"];
    [filterProgram addAttribute:@"inputTextureCoordinate8"];
}

- (void)disableFifthFrameCheck;
{
    fifthFrameCheckDisabled = YES;
}

- (void)disableSixthFrameCheck;
{
    sixthFrameCheckDisabled = YES;
}

- (void)disableSeventhFrameCheck;
{
    seventhFrameCheckDisabled = YES;
}

- (void)disableEighthFrameCheck;
{
    eighthFrameCheckDisabled = YES;
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        [thirdInputFramebuffer unlock];
        [fourthInputFramebuffer unlock];
        [fifthInputFramebuffer unlock];
        [sixthInputFramebuffer unlock];
        [seventhInputFramebuffer unlock];
        [eighthInputFramebuffer unlock];
        return;
    }

    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }

    [self setUniformsForProgramAtIndex:0];

    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);

	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
	glUniform1i(filterInputTextureUniform, 2);

    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [thirdInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform3, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, [fourthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform4, 5);

    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, [fifthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform5, 6);

    glActiveTexture(GL_TEXTURE7);
    glBindTexture(GL_TEXTURE_2D, [sixthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform6, 7);

    glActiveTexture(GL_TEXTURE8);
    glBindTexture(GL_TEXTURE_2D, [seventhInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform7, 8);

    glActiveTexture(GL_TEXTURE9);
    glBindTexture(GL_TEXTURE_2D, [eighthInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform8, 9);

    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    glVertexAttribPointer(filterThirdTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation3]);
    glVertexAttribPointer(filterFourthTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation4]);
    glVertexAttribPointer(filterFifthTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation5]);
    glVertexAttribPointer(filterSixthTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation6]);
    glVertexAttribPointer(filterSeventhTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation7]);
    glVertexAttribPointer(filterEighthTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation8]);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    [thirdInputFramebuffer unlock];
    [fourthInputFramebuffer unlock];
    [fifthInputFramebuffer unlock];
    [sixthInputFramebuffer unlock];
    [seventhInputFramebuffer unlock];
    [eighthInputFramebuffer unlock];

    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

#pragma mark -
#pragma mark GPUImageInput

- (NSInteger)nextAvailableTextureIndex;
{
    if (hasSetSeventhTexture)
    {
        return 7;
    }
    else if (hasSetSixthTexture)
    {
        return 6;
    }
    else if (hasSetFifthTexture)
    {
        return 5;
    }
    else if (hasSetFourthTexture)
    {
        return 4;
    }
    else if (hasSetThirdTexture)
    {
        return 3;
    }
    else if (hasSetSecondTexture)
    {
        return 2;
    }
    else if (hasSetFirstTexture)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        hasSetFirstTexture = YES;
        [firstInputFramebuffer lock];
    }
    else if (textureIndex == 1)
    {
        secondInputFramebuffer = newInputFramebuffer;
        hasSetSecondTexture = YES;
        [secondInputFramebuffer lock];
    }
    else if (textureIndex == 2)
    {
        thirdInputFramebuffer = newInputFramebuffer;
        hasSetThirdTexture = YES;
        [thirdInputFramebuffer lock];
    }
    else if (textureIndex == 3)
    {
        fourthInputFramebuffer = newInputFramebuffer;
        hasSetFourthTexture = YES;
        [fourthInputFramebuffer lock];
    }
    else if (textureIndex == 4)
    {
        fifthInputFramebuffer = newInputFramebuffer;
        hasSetFifthTexture = YES;
        [fifthInputFramebuffer lock];
    }
    else if (textureIndex == 5)
    {
        sixthInputFramebuffer = newInputFramebuffer;
        hasSetSixthTexture = YES;
        [sixthInputFramebuffer lock];
    }
    else if (textureIndex == 6)
    {
        seventhInputFramebuffer = newInputFramebuffer;
        hasSetSeventhTexture = YES;
        [seventhInputFramebuffer lock];
    }
    else
    {
        eighthInputFramebuffer = newInputFramebuffer;
        [eighthInputFramebuffer lock];
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        [super setInputSize:newSize atIndex:textureIndex];

        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFirstTexture = NO;
        }
    }
    else if (textureIndex == 1)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSecondTexture = NO;
        }
    }
    else if (textureIndex == 2)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetThirdTexture = NO;
        }
    }
    else if (textureIndex == 3)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFourthTexture = NO;
        }
    }
    else if (textureIndex == 4)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetFifthTexture = NO;
        }
    }
    else if (textureIndex == 5)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSixthTexture = NO;
        }
    }
    else if (textureIndex == 6)
    {
        if (CGSizeEqualToSize(newSize, CGSizeZero))
        {
            hasSetSeventhTexture = NO;
        }
    }
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        inputRotation = newInputRotation;
    }
    else if (textureIndex == 1)
    {
        inputRotation2 = newInputRotation;
    }
    else if (textureIndex == 2)
    {
        inputRotation3 = newInputRotation;
    }
    else if (textureIndex == 3)
    {
        inputRotation4 = newInputRotation;
    }
    else if (textureIndex == 4)
    {
        inputRotation5 = newInputRotation;
    }
    else if (textureIndex == 5)
    {
        inputRotation6 = newInputRotation;
    }
    else if (textureIndex == 6)
    {
        inputRotation7 = newInputRotation;
    }
    else
    {
        inputRotation8 = newInputRotation;
    }
}

- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
{
    CGSize rotatedSize = sizeToRotate;

    GPUImageRotationMode rotationToCheck;
    if (textureIndex == 0)
    {
        rotationToCheck = inputRotation;
    }
    else if (textureIndex == 1)
    {
        rotationToCheck = inputRotation2;
    }
    else if (textureIndex == 2)
    {
        rotationToCheck = inputRotation3;
    }
    else if (textureIndex == 3)
    {
        rotationToCheck = inputRotation4;
    }
    else if (textureIndex == 4)
    {
        rotationToCheck = inputRotation5;
    }
    else if (textureIndex == 5)
    {
        rotationToCheck = inputRotation6;
    }
    else if (textureIndex == 6)
    {
        rotationToCheck = inputRotation7;
    }
    else
    {
        rotationToCheck = inputRotation8;
    }

    if (GPUImageRotationSwapsWidthAndHeight(rotationToCheck))
    {
        rotatedSize.width = sizeToRotate.height;
        rotatedSize.height = sizeToRotate.width;
    }

    return rotatedSize;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    // You can set up infinite update loops, so this helps to short circuit them
    if (hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame && hasReceivedFifthFrame && hasReceivedSixthFrame && hasReceivedSeventhFrame && hasReceivedEighthFrame)
    {
        return;
    }

    BOOL updatedMovieFrameOppositeStillImage = NO;

    if (textureIndex == 0)
    {
        hasReceivedFirstFrame = YES;
        firstFrameTime = frameTime;
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(secondFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 1)
    {
        hasReceivedSecondFrame = YES;
        secondFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 2)
    {
        hasReceivedThirdFrame = YES;
        thirdFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 3)
    {
        hasReceivedFourthFrame = YES;
        fourthFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 4)
    {
        hasReceivedFifthFrame = YES;
        fifthFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 5)
    {
        hasReceivedSixthFrame = YES;
        sixthFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else if (textureIndex == 6)
    {
        hasReceivedSeventhFrame = YES;
        seventhFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (eighthFrameCheckDisabled)
        {
            hasReceivedEighthFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }
    else
    {
        hasReceivedEighthFrame = YES;
        eighthFrameTime = frameTime;
        if (firstFrameCheckDisabled)
        {
            hasReceivedFirstFrame = YES;
        }
        if (secondFrameCheckDisabled)
        {
            hasReceivedSecondFrame = YES;
        }
        if (thirdFrameCheckDisabled)
        {
            hasReceivedThirdFrame = YES;
        }
        if (fourthFrameCheckDisabled)
        {
            hasReceivedFourthFrame = YES;
        }
        if (fifthFrameCheckDisabled)
        {
            hasReceivedFifthFrame = YES;
        }
        if (sixthFrameCheckDisabled)
        {
            hasReceivedSixthFrame = YES;
        }
        if (seventhFrameCheckDisabled)
        {
            hasReceivedSeventhFrame = YES;
        }

        if (!CMTIME_IS_INDEFINITE(frameTime))
        {
            if CMTIME_IS_INDEFINITE(firstFrameTime)
            {
                updatedMovieFrameOppositeStillImage = YES;
            }
        }
    }

    if ((hasReceivedFirstFrame && hasReceivedSecondFrame && hasReceivedThirdFrame && hasReceivedFourthFrame && hasReceivedFifthFrame && hasReceivedSixthFrame && hasReceivedSeventhFrame && hasReceivedEighthFrame) || updatedMovieFrameOppositeStillImage)
    {
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };

        [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];

        [self informTargetsAboutNewFrameAtTime:frameTime];

        hasReceivedFirstFrame = NO;
        hasReceivedSecondFrame = NO;
        hasReceivedThirdFrame = NO;
        hasReceivedFourthFrame = NO;
        hasReceivedFifthFrame = NO;
        hasReceivedSixthFrame = NO;
        hasReceivedSeventhFrame = NO;
        hasReceivedEighthFrame = NO;
    }
}

@end
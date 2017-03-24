//
// Created by wangyang on 2017/3/13.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import "SquareARViewController.h"
#import "EZGL.h"
#import "ARSquareMarkerDetector.h"
#import "ARSDK/ARMarkerPose.h"


@interface SquareARViewController () {
    ELWorld *world;
}

@property  (strong, nonatomic) ARSquareMarkerDetector *markDetector;
@end

@implementation SquareARViewController

#define  Bit(n) (0x00000001 << n)

enum CollisionTypes {
    CT_Floor = Bit(0),
    CT_Prop = Bit(1),
    CT_Prop2 = Bit(2),
    CT_Role = Bit(3),
    CT_Prop3 = Bit(4)
};


ELGameObject * createCubeGameObject2(ELWorld *world, ELVector3 size,ELVector3 pos,ELFloat mass,GLuint diffuseMap,GLuint normalMap, bool hasBorder, int collisionGroup, int collisionMask, ELVector3 velocity, bool hasGeometry = false) {
    
    diffuseMap = ELTexture::texture(ELAssets::shared()->findFile("stone_ground.png"))->value;
    //    normalMap = ELTexture::texture(ELAssets::shared()->findFile("stone_ground_normal.png"))->value;
    
    ELGameObject *gameObject = new ELGameObject(world);
    world->addNode(gameObject);
    gameObject->transform->position = pos;
    gameObject->transform->scale = ELVector3Make(1,1,1);
    if (hasGeometry) {
        ELCubeGeometry *cube = new ELCubeGeometry(size);
        gameObject->addComponent(cube);
        cube->materials[0].diffuse = ELVector4Make(0.3, 0.3, 0.3, 1.0);
        cube->materials[0].ambient = ELVector4Make(0.3,0.3,0.3, 1.0);
        cube->materials[0].diffuseMap = diffuseMap;
        cube->materials[0].normalMap = normalMap;
        cube->enableBorder = hasBorder;
        cube->borderWidth = 0.2;
        cube->borderColor = ELVector4Make(1, 0, 0, 1);
        
    }
    
    ELCollisionShape *collisionShape = new ELCollisionShape();
    collisionShape->asBox(ELVector3Make(size.x / 2, size.y / 2, size.z / 2));
    ELRigidBody *rigidBody = new ELRigidBody(collisionShape, mass);
    rigidBody->collisionGroup = collisionGroup;
    rigidBody->collisionMask = collisionMask;
    rigidBody->friction = 0.5;
    gameObject->addComponent(rigidBody);
    
    return gameObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.markDetector = [ARSquareMarkerDetector new];
    world = [self world];
    ELPhysicsWorld::shared()->setGravity(ELVector3Make(0,0,-100));
}

#pragma mark - Provide Marker Detector

- (id<ARMarkerDetector>)preferMarkerDetector {
    return self.markDetector;
}

#pragma mark - AR Lifecycle

- (void)arDidBeganDetect {
    GLuint diffuseTex = ELTexture::texture(ELAssets::shared()->findFile("grass_yellow.jpg"))->value;
    createCubeGameObject2(world, ELVector3Make(1000,1000,10), ELVector3Make(0,0,0.0), 0, 0, 0, NO, CT_Floor, CT_Prop, ELVector3Make(0, 0, 0));
    for (int i = 0; i < 10; i++) {
        srand(rand());
        float randx = rand()/(float)RAND_MAX * 40 - 20;
        float randy = rand()/(float)RAND_MAX * 40 - 20;
        createCubeGameObject2(world, ELVector3Make(5,5,5), ELVector3Make(randx,randy,38 + i * 14), 10, diffuseTex, 0, NO, CT_Prop, CT_Prop | CT_Floor, ELVector3Make(0, 0, 0), true);
    }
}

- (void)arDetecting:(NSArray *)poses {
    if ([poses count] > 0) {
        ARMarkerPose *pose = (ARMarkerPose *)poses[0];
        world->activedCamera->setMatrixDirect([pose matrix]);
    } else {
        float matrix[16];
        memset(matrix, 0x00, sizeof(float) * 16);
        world->activedCamera->setMatrixDirect(matrix);
    }
}

- (void)arDidPauseDetect {
    
}

- (void)arDidResumeDetect {
    
}

- (void)arDidEndDetect {
    
}


@end

//
//  DynamicLayout.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "DynamicLayout.h"

@implementation DynamicLayout

+(instancetype)with:(UIView *)view
{
    return [[DynamicLayout alloc] initWithView:view];
}

-(instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if(self)
    {
        _bounds = view.bounds;
    }
    return self;
}


@end

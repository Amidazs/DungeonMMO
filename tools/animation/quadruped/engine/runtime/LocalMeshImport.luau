--!strict
-- Unpublished QA bridge: creates local EditableMeshes; never uploads assets.
local Import={}
function Import.build(manifest,fetchMesh)
    assert(game:GetService("RunService"):IsStudio() and game.PlaceId==0,"Unpublished Studio QA only")
    local asset=game:GetService("AssetService")
    local model=Instance.new("Model");model.Name="QAE_Frostfang_V3"
    local root=Instance.new("MeshPart");root.Name="RootPart";root.Anchored=true;root.Transparency=1;root.CanCollide=false;root.Parent=model;model.PrimaryPart=root
    local bones={}
    for _,b in manifest.bones do
        local bone=Instance.new("Bone");bone.Name=b.name;bone.CFrame=CFrame.new(table.unpack(b.local));bones[b.name]=bone
    end
    for _,b in manifest.bones do bones[b.name].Parent=if b.parent then assert(bones[b.parent],"missing parent") else root end
    local meshes={}
    local ok,err=pcall(function()
        for index,file in manifest.meshFiles do
            local packet=fetchMesh(file)
            local mesh=assert(asset:CreateEditableMesh(),"EditableMesh budget exhausted")
            local entry={mesh=mesh,bones={}};table.insert(meshes,entry)
            for _,b in manifest.bones do
                entry.bones[b.name]=mesh:AddBone({Name=b.name,ParentId=if b.parent then entry.bones[b.parent] else nil,CFrame=CFrame.new(table.unpack(b.bind)),Virtual=false})
            end
            local vertices={}
            for i,v in packet.vertices do
                local id=mesh:AddVertex(Vector3.new(table.unpack(v.p)));vertices[i]=id
                local ids={};for _,n in v.bones do table.insert(ids,assert(entry.bones[n],"missing weight bone")) end
                mesh:SetVertexBones(id,ids);mesh:SetVertexBoneWeights(id,v.weights)
            end
            for _,face in packet.faces do
                local id=mesh:AddTriangle(vertices[face.v[1]],vertices[face.v[2]],vertices[face.v[3]])
                local uv={};for _,v in face.uv do table.insert(uv,mesh:AddUV(Vector2.new(v[1],v[2]))) end
                mesh:SetFaceUVs(id,uv)
                if face.normals then
                    local normals={};for _,n in face.normals do table.insert(normals,mesh:AddNormal(Vector3.new(table.unpack(n)))) end
                    mesh:SetFaceNormals(id,normals)
                end
            end
            local part=asset:CreateMeshPartAsync(Content.fromObject(mesh))
            part.Name="Skin_"..index;part.Anchored=true;part.CanCollide=false;part.DoubleSided=true
            part.Color=Color3.new(.64,.635,.647);part.Parent=model
            -- MeshPart recenters its vertex bounds: restore original model space.
            part.CFrame=CFrame.new(mesh:GetCenter())
            entry.part=part
        end
    end)
    if not ok then model:Destroy();for _,e in meshes do e.mesh:Destroy() end;error(err) end
    local ac=Instance.new("AnimationController");ac.Parent=model
    local animator=Instance.new("Animator");animator.Parent=ac
    local handle={model=model,meshes=meshes,bones=bones,animator=animator}
    function handle:sync()
        for _,e in self.meshes do
            for name,id in e.bones do e.mesh:SetBoneCFrame(id,root.CFrame:ToObjectSpace(self.bones[name].TransformedWorldCFrame)) end
        end
    end
    function handle:destroy()
        if self.connection then self.connection:Disconnect() end
        self.model:Destroy();for _,e in self.meshes do e.mesh:Destroy() end
    end
    handle.connection=game:GetService("RunService").PreSimulation:Connect(function() handle:sync() end)
    return handle
end
return Import
